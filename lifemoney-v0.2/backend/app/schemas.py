from pydantic import BaseModel, Field


class GoalRequest(BaseModel):
    current_cost: float = Field(gt=0)
    years: int = Field(gt=0, le=80)
    inflation_rate: float = Field(default=0.06, gt=-0.99, lt=1)
    annual_return: float = Field(default=0.10, gt=-0.99, lt=2)
    current_corpus: float = Field(default=0, ge=0)
    annual_step_up: float = Field(default=0.10, gt=-0.99, lt=2)


class GoalResponse(BaseModel):
    future_cost: float
    monthly_sip_flat: float
    monthly_sip_step_up: float


class RetirementRequest(BaseModel):
    current_age: int = Field(ge=18, le=80)
    retirement_age: int = Field(ge=25, le=90)
    life_expectancy: int = Field(default=90, ge=50, le=120)
    current_monthly_expense: float = Field(gt=0)
    current_corpus: float = Field(ge=0)
    annual_inflation: float = Field(default=0.06, gt=-0.99, lt=1)
    pre_retirement_return: float = Field(default=0.10, gt=-0.99, lt=2)
    post_retirement_return: float = Field(default=0.08, gt=-0.99, lt=2)
    monthly_investment: float = Field(default=0, ge=0)
    annual_step_up: float = Field(default=0.10, gt=-0.99, lt=2)


class RetirementRow(BaseModel):
    age: int
    opening_corpus: float
    annual_expense: float
    investment_return: float
    closing_corpus: float


class RetirementResponse(BaseModel):
    years_to_retirement: int
    expense_at_retirement_monthly: float
    projected_corpus_at_retirement: float
    survives_to_life_expectancy: bool
    corpus_at_life_expectancy: float
    depletion_age: int | None
    timeline: list[RetirementRow]


class AffordabilityRequest(BaseModel):
    purchase_price: float = Field(gt=0)
    current_liquid_corpus: float = Field(ge=0)
    protected_reserve: float = Field(default=0, ge=0)
    monthly_surplus: float = Field(default=0, ge=0)
    annual_return: float = Field(default=0.08, gt=-0.99, lt=2)
    horizon_years: int = Field(default=5, ge=1, le=50)


class AffordabilityResponse(BaseModel):
    affordable_now: bool
    investable_after_purchase: float
    future_value_if_bought_now: float
    future_value_if_not_bought: float
    opportunity_cost_at_horizon: float
    months_to_afford_without_touching_reserve: int | None
