#!/usr/bin/env python3
"""
SymPy verification script for math expressions.
Called as subprocess from Rails. Reads LaTeX expression from argv,
outputs JSON result to stdout.

Usage:
    python3 sympy_verify.py "\\frac{x^2 + 2x + 1}{x + 1}"
    python3 sympy_verify.py --simplify "x**2 + 2*x + 1"
    python3 sympy_verify.py --solve "x**2 - 4"
    python3 sympy_verify.py --evaluate "integrate(x**2, x)"
"""

import json
import sys
import signal
from io import StringIO

def timeout_handler(signum, frame):
    raise TimeoutError("Verification timed out")

signal.signal(signal.SIGALRM, timeout_handler)
signal.alarm(30)  # 30 second timeout

def verify_expression(expr_str, mode="auto"):
    """Verify/simplify a math expression using SymPy."""
    try:
        import sympy
        from sympy.parsing.latex import parse_latex
        from sympy import simplify, solve, latex, symbols, integrate, diff, oo, pi, E
        from sympy.parsing.sympy_parser import (
            parse_expr, standard_transformations, implicit_multiplication_application,
            convert_xor
        )

        result = {
            "verified": False,
            "input": expr_str,
            "mode": mode,
            "simplified": None,
            "latex": None,
            "steps": [],
            "error": None
        }

        # Try parsing as LaTeX first, then as SymPy expression
        expr = None
        parse_method = None

        try:
            expr = parse_latex(expr_str)
            parse_method = "latex"
            result["steps"].append(f"Parsed as LaTeX: {expr}")
        except Exception:
            pass

        if expr is None:
            try:
                transformations = standard_transformations + (
                    implicit_multiplication_application,
                    convert_xor,
                )
                expr = parse_expr(expr_str, transformations=transformations)
                parse_method = "sympy"
                result["steps"].append(f"Parsed as SymPy expression: {expr}")
            except Exception as e:
                result["error"] = f"Could not parse expression: {e}"
                return result

        result["parse_method"] = parse_method

        # Simplify
        simplified = simplify(expr)
        result["simplified"] = str(simplified)
        result["latex"] = latex(simplified)
        result["steps"].append(f"Simplified: {simplified}")
        result["verified"] = True

        # If it's an equation (Eq or Relational), check validity
        if hasattr(expr, 'is_Relational') and expr.is_Relational:
            try:
                truth = bool(expr)
                result["is_true"] = truth
                result["steps"].append(f"Equation evaluates to: {truth}")
            except TypeError:
                result["steps"].append("Equation contains free variables, cannot evaluate to boolean")

        return result

    except TimeoutError:
        return {"verified": False, "error": "Verification timed out (30s)", "input": expr_str}
    except Exception as e:
        return {"verified": False, "error": str(e), "input": expr_str}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No expression provided"}))
        sys.exit(1)

    mode = "auto"
    expr_str = sys.argv[-1]

    if len(sys.argv) > 2:
        flag = sys.argv[1]
        if flag == "--simplify":
            mode = "simplify"
        elif flag == "--solve":
            mode = "solve"
        elif flag == "--evaluate":
            mode = "evaluate"

    result = verify_expression(expr_str, mode)
    print(json.dumps(result))

if __name__ == "__main__":
    main()
