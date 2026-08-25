from fastapi.testclient import TestClient

from app.main import app
from app.money_engine.core import future_cost, monthly_sip_for_target, future_value_of_step_up_sip

client = TestClient(app)


def test_future_cost():
    assert round(future_cost(1_000_000, 0.06, 10), 2) == 1_790_847.70


def test_flat_sip_zero_if_current_corpus_already_enough():
    assert monthly_sip_for_target(1_000_000, 1_000_000, 0.10, 10) == 0


def test_step_up_sip_grows_more_than_flat_contribution_without_returns():
    stepped = future_value_of_step_up_sip(10_000, 0.10, 0.0, 5)
    flat = 10_000 * 60
    assert stepped > flat


def test_goal_api():
    r = client.post(
        "/v1/goals/calculate",
        json={
            "current_cost": 5_000_000,
            "years": 10,
            "inflation_rate": 0.08,
            "annual_return": 0.10,
            "current_corpus": 1_000_000,
            "annual_step_up": 0.10,
        },
    )
    assert r.status_code == 200
    body = r.json()
    assert body["future_cost"] > 5_000_000
    assert body["monthly_sip_step_up"] < body["monthly_sip_flat"]


def test_retirement_api():
    r = client.post(
        "/v1/retirement/simulate",
        json={
            "current_age": 38,
            "retirement_age": 50,
            "life_expectancy": 90,
            "current_monthly_expense": 100000,
            "current_corpus": 20000000,
            "monthly_investment": 100000,
            "annual_inflation": 0.06,
            "pre_retirement_return": 0.10,
            "post_retirement_return": 0.08,
            "annual_step_up": 0.10
        },
    )
    assert r.status_code == 200
    body = r.json()
    assert body["years_to_retirement"] == 12
    assert len(body["timeline"]) == 40


def test_affordability_api():
    r = client.post(
        "/v1/affordability/check",
        json={
            "purchase_price": 1000000,
            "current_liquid_corpus": 1500000,
            "protected_reserve": 400000,
            "monthly_surplus": 50000,
            "annual_return": 0.08,
            "horizon_years": 5
        },
    )
    assert r.status_code == 200
    body = r.json()
    assert body["affordable_now"] is True
    assert body["months_to_afford_without_touching_reserve"] == 0
    assert body["opportunity_cost_at_horizon"] > 1_000_000
