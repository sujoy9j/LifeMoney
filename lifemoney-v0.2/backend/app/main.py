from math import ceil
import os

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .money_engine.core import (
    future_cost,
    future_value,
    future_value_of_step_up_sip,
    monthly_sip_for_target,
    simulate_retirement,
    sip_for_target_with_step_up,
)
from .schemas import (
    AffordabilityRequest,
    AffordabilityResponse,
    GoalRequest,
    GoalResponse,
    RetirementRequest,
    RetirementResponse,
    RetirementRow,
)

API_VERSION = "0.2.0"

raw_origins = os.getenv("CORS_ORIGINS", "*")
allowed_origins = [origin.strip() for origin in raw_origins.split(",") if origin.strip()]

app = FastAPI(
    title="LifeMoney API",
    version=API_VERSION,
    description="India-first life and money simulation engine. Educational planning only; no security recommendations.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root() -> dict[str, str]:
    return {
        "service": "LifeMoney API",
        "version": API_VERSION,
        "status": "online",
        "docs": "/docs",
    }


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "version": API_VERSION}


@app.post("/v1/goals/calculate", response_model=GoalResponse)
def calculate_goal(req: GoalRequest) -> GoalResponse:
    target = future_cost(req.current_cost, req.inflation_rate, req.years)
    return GoalResponse(
        future_cost=round(target, 2),
        monthly_sip_flat=round(
            monthly_sip_for_target(target, req.current_corpus, req.annual_return, req.years), 2
        ),
        monthly_sip_step_up=round(
            sip_for_target_with_step_up(
                target, req.current_corpus, req.annual_return, req.years, req.annual_step_up
            ),
            2,
        ),
    )


@app.post("/v1/retirement/simulate", response_model=RetirementResponse)
def retirement(req: RetirementRequest) -> RetirementResponse:
    years = req.retirement_age - req.current_age
    if years <= 0:
        raise HTTPException(400, "retirement_age must be greater than current_age")
    if req.life_expectancy <= req.retirement_age:
        raise HTTPException(400, "life_expectancy must be greater than retirement_age")

    current_growth = future_value(req.current_corpus, req.pre_retirement_return, years)
    sip_growth = future_value_of_step_up_sip(
        req.monthly_investment, req.annual_step_up, req.pre_retirement_return, years
    )
    retirement_corpus = current_growth + sip_growth
    monthly_expense_at_ret = future_cost(
        req.current_monthly_expense, req.annual_inflation, years
    )

    rows = simulate_retirement(
        retirement_corpus,
        req.retirement_age,
        req.life_expectancy,
        monthly_expense_at_ret * 12,
        req.annual_inflation,
        req.post_retirement_return,
    )
    depletion_age = next((r.age for r in rows if r.closing_corpus <= 0), None)
    mapped = [
        RetirementRow(
            age=r.age,
            opening_corpus=round(r.opening_corpus, 2),
            annual_expense=round(r.annual_expense, 2),
            investment_return=round(r.investment_return, 2),
            closing_corpus=round(r.closing_corpus, 2),
        )
        for r in rows
    ]
    final_corpus = mapped[-1].closing_corpus if mapped else retirement_corpus
    return RetirementResponse(
        years_to_retirement=years,
        expense_at_retirement_monthly=round(monthly_expense_at_ret, 2),
        projected_corpus_at_retirement=round(retirement_corpus, 2),
        survives_to_life_expectancy=depletion_age is None,
        corpus_at_life_expectancy=round(final_corpus, 2),
        depletion_age=depletion_age,
        timeline=mapped,
    )


@app.post("/v1/affordability/check", response_model=AffordabilityResponse)
def affordability(req: AffordabilityRequest) -> AffordabilityResponse:
    available = max(0.0, req.current_liquid_corpus - req.protected_reserve)
    affordable = available >= req.purchase_price
    after_purchase = max(0.0, available - req.purchase_price)

    with_purchase_future = future_value(after_purchase, req.annual_return, req.horizon_years)
    without_purchase_future = future_value(available, req.annual_return, req.horizon_years)
    opportunity_cost = without_purchase_future - with_purchase_future

    if affordable:
        months = 0
    elif req.monthly_surplus <= 0:
        months = None
    else:
        gap = req.purchase_price - available
        monthly_rate = (1 + req.annual_return) ** (1 / 12) - 1
        balance = available
        months = 0
        while balance < req.purchase_price and months < 1200:
            balance = balance * (1 + monthly_rate) + req.monthly_surplus
            months += 1
        if months >= 1200:
            months = ceil(gap / req.monthly_surplus)

    return AffordabilityResponse(
        affordable_now=affordable,
        investable_after_purchase=round(after_purchase, 2),
        future_value_if_bought_now=round(with_purchase_future, 2),
        future_value_if_not_bought=round(without_purchase_future, 2),
        opportunity_cost_at_horizon=round(opportunity_cost, 2),
        months_to_afford_without_touching_reserve=months,
    )
