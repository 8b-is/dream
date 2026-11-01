#!/usr/bin/env python3
"""
Hue's Relationship-Proximity & Reverse-Tax Graph Mechanism (Shinjuku, 2026-11-01)
=================================================================================
From the Shinjuku 3-Node FlugOS Triad field video (L6467, 00:05-00:43):
  - "Taxing people for their relationships... So if you're related to an arms
     dealer, right, or you're dealing with the arms dealer, then your tax goes
     higher."
  - "But if you're not related to anybody that's bad, then you actually have
     reverse tax, and you actually get paid!"

Mathematical Formulation (Column A <-> Column B):
  1. Graph Harm-Proximity Diffusion (Katz / Resolvent Kernel):
       p = (I - beta * W)^{-1} h = sum_{d=0..inf} (beta * W)^d h
     where W_{ij} in [0, 1] is the normalized transaction/relationship coupling
     from node i to node j, h_j >= 0 is the direct harm / externality index
     (e.g., arms dealer h = 1.0), and beta in (0, 1) is the per-hop attenuation.
  2. Budget-Balanced Neutrality Threshold (theta_0):
       theta_0 = (sum_i Y_i * p_i) / (sum_i Y_i)
     where Y_i > 0 is node i's gross flow/income.
  3. Effective Tax / Reverse-Tax Rate (tau_i):
       tau_i = kappa * (p_i - theta_0)
       Net Tax Liability T_i = tau_i * Y_i
     * If p_i > theta_0 (dealing with or proximate to harmful actors):
         tau_i > 0  ->  Positive surcharge proportional to harm proximity.
     * If p_i == 0 < theta_0 (unconnected to harmful actors):
         tau_i < 0  ->  Negative tax ("Reverse Tax"): node i gets paid a peace
                        dividend funded 100% by the high-harm surcharge pool:
                        sum_i T_i == 0 (strictly budget-balanced).
"""

from __future__ import annotations
import json


def solve_harm_proximity(
    adj_weights: list[list[float]],
    harm_source: list[float],
    beta: float = 0.5,
    iterations: int = 64,
) -> list[float]:
    """Compute p = sum_{d=0..inf} (beta * W)^d h via fixed-point iteration."""
    n = len(harm_source)
    p = list(harm_source)
    for _ in range(iterations):
        next_p = []
        for i in range(n):
            coupled = sum(adj_weights[i][j] * p[j] for j in range(n))
            next_p.append(harm_source[i] + beta * coupled)
        p = next_p
    return p


def compute_relationship_reverse_tax(
    names: list[str],
    adj_weights: list[list[float]],
    harm_source: list[float],
    incomes: list[float],
    beta: float = 0.5,
    kappa: float = 0.45,
) -> dict:
    p = solve_harm_proximity(adj_weights, harm_source, beta=beta)
    total_income = sum(incomes)
    theta_0 = sum(y * pi for y, pi in zip(incomes, p)) / total_income

    nodes = []
    net_revenue = 0.0
    for name, pi, h0, y in zip(names, p, harm_source, incomes):
        tau_i = kappa * (pi - theta_0)
        tax_amount = tau_i * y
        net_revenue += tax_amount
        nodes.append({
            "participant": name,
            "direct_harm_h": round(h0, 4),
            "harm_proximity_p": round(pi, 4),
            "gross_income": round(y, 2),
            "effective_tax_rate_pct": round(tau_i * 100.0, 2),
            "net_tax_or_payout": round(tax_amount, 2),
            "regime": "SURCHARGE_TAX" if tax_amount > 1e-6 else ("REVERSE_TAX_PAYOUT" if tax_amount < -1e-6 else "NEUTRAL"),
        })

    assert abs(net_revenue) < 1e-6, f"Budget balance violated: {net_revenue}"
    return {
        "beta_hop_decay": beta,
        "kappa_scale": kappa,
        "neutral_harm_threshold_theta0": round(theta_0, 6),
        "net_treasury_imbalance": round(net_revenue, 9),
        "nodes": nodes,
    }


if __name__ == "__main__":
    names = [
        "Arms_Dealer_Node_0",
        "Direct_Financier_1Hop",
        "Shell_Broker_2Hop",
        "Independent_Builder_Hue",
        "Independent_Engineer_Peter",
    ]
    # Row-stochastic / coupling matrix W_{ij}
    W = [
        [0.0, 0.4, 0.0, 0.0, 0.0],
        [0.8, 0.0, 0.2, 0.0, 0.0],
        [0.0, 0.5, 0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0, 0.0, 0.5],
        [0.0, 0.0, 0.0, 0.5, 0.0],
    ]
    h = [1.0, 0.0, 0.0, 0.0, 0.0]
    incomes = [1000.0, 500.0, 300.0, 200.0, 200.0]

    report = compute_relationship_reverse_tax(names, W, h, incomes)
    print(json.dumps(report, indent=2))
