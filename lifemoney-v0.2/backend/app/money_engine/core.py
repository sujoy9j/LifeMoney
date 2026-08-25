from __future__ import annotations

from dataclasses import dataclass
from math import isfinite


def _validate_rate(name: str, value: float, floor: float = -0.99) -> None:
    if not isfinite(value) or value <= floor:
        raise ValueError(f"{name} must be finite and greater than {floor}")


def future_value(present_value: float, annual_rate: float, years: float) -> float:
    """Future value with annual compounding."""
    if years < 0:
        raise ValueError("years cannot be negative")
    _validate_rate("annual_rate", annual_rate)
    return present_value * ((1 + annual_rate) ** years)


def future_cost(current_cost: float, inflation_rate: float, years: float) -> float:
    if current_cost < 0:
        raise ValueError("current_cost cannot be negative")
    return future_value(current_cost, inflation_rate, years)


def monthly_sip_for_target(
    target_value: float,
    current_corpus: float,
    annual_return: float,
    years: float,
) -> float:
    """Monthly SIP required, assuming end-of-month contributions."""
    if target_value < 0 or current_corpus < 0 or years <= 0:
        raise ValueError("target/current corpus must be non-negative and years positive")
    _validate_rate("annual_return", annual_return)
    months = max(1, round(years * 12))
    monthly_rate = (1 + annual_return) ** (1 / 12) - 1
    corpus_fv = current_corpus * ((1 + monthly_rate) ** months)
    gap = max(0.0, target_value - corpus_fv)
    if gap == 0:
        return 0.0
    if abs(monthly_rate) < 1e-12:
        return gap / months
    annuity_factor = (((1 + monthly_rate) ** months) - 1) / monthly_rate
    return gap / annuity_factor


def future_value_of_step_up_sip(
    monthly_sip: float,
    annual_step_up: float,
    annual_return: float,
    years: int,
) -> float:
    """Month-by-month SIP with annual increase applied every 12 months."""
    if monthly_sip < 0 or years < 0:
        raise ValueError("monthly_sip and years cannot be negative")
    _validate_rate("annual_step_up", annual_step_up)
    _validate_rate("annual_return", annual_return)
    monthly_rate = (1 + annual_return) ** (1 / 12) - 1
    balance = 0.0
    contribution = monthly_sip
    for month in range(1, years * 12 + 1):
        balance *= 1 + monthly_rate
        balance += contribution
        if month % 12 == 0:
            contribution *= 1 + annual_step_up
    return balance


def sip_for_target_with_step_up(
    target_value: float,
    current_corpus: float,
    annual_return: float,
    years: int,
    annual_step_up: float,
) -> float:
    """Solve initial monthly SIP by scaling a ₹1 step-up contribution stream."""
    if years <= 0:
        raise ValueError("years must be positive")
    target_after_current = max(0.0, target_value - future_value(current_corpus, annual_return, years))
    if target_after_current == 0:
        return 0.0
    factor = future_value_of_step_up_sip(1.0, annual_step_up, annual_return, years)
    return target_after_current / factor


@dataclass(frozen=True)
class RetirementYear:
    year_index: int
    age: int
    opening_corpus: float
    annual_expense: float
    investment_return: float
    closing_corpus: float


def simulate_retirement(
    starting_corpus: float,
    retirement_age: int,
    life_expectancy: int,
    annual_expense_at_retirement: float,
    inflation_rate: float,
    annual_return: float,
) -> list[RetirementYear]:
    """Deterministic annual retirement decumulation. Withdrawal occurs at year start."""
    if starting_corpus < 0 or annual_expense_at_retirement < 0:
        raise ValueError("starting_corpus/expense cannot be negative")
    if retirement_age >= life_expectancy:
        raise ValueError("life_expectancy must exceed retirement_age")
    _validate_rate("inflation_rate", inflation_rate)
    _validate_rate("annual_return", annual_return)

    rows: list[RetirementYear] = []
    corpus = starting_corpus
    expense = annual_expense_at_retirement
    for idx, age in enumerate(range(retirement_age, life_expectancy), start=1):
        opening = corpus
        after_withdrawal = max(0.0, corpus - expense)
        gain = after_withdrawal * annual_return
        corpus = after_withdrawal + gain
        rows.append(
            RetirementYear(
                year_index=idx,
                age=age,
                opening_corpus=opening,
                annual_expense=expense,
                investment_return=gain,
                closing_corpus=corpus,
            )
        )
        expense *= 1 + inflation_rate
    return rows
