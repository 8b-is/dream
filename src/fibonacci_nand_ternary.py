#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
pocoo · one sequence, base three, one gate · fine touch from within · vaked.dev
Fibonacci (OEIS A000045) in balanced ternary {-1, 0, +1}, carried by NAND gates alone.
"""

def nand(a: int, b: int) -> int:
    return 0 if (a & 1) and (b & 1) else 1

def b_not(a: int) -> int:
    return nand(a, a)

def b_and(a: int, b: int) -> int:
    return b_not(nand(a, b))

def b_or(a: int, b: int) -> int:
    return nand(b_not(a), b_not(b))

def b_xor(a: int, b: int) -> int:
    return b_and(nand(a, b), b_or(a, b))

def add_nand(x: int, y: int, width: int = 64) -> int:
    carry = 0
    out = 0
    for i in range(width):
        xi = (x >> i) & 1
        yi = (y >> i) & 1
        xory = b_xor(xi, yi)
        s = b_xor(xory, carry)
        carry = b_or(b_and(xi, yi), b_and(carry, xory))
        if s:
            out |= (1 << i)
    return out

def balanced_ternary(n: int) -> str:
    if n == 0:
        return "0"
    digits = []
    val = n
    while val != 0:
        rem = val % 3
        val //= 3
        if rem == 2:
            rem = -1
            val = add_nand(val, 1)
        digits.append("-" if rem == -1 else ("+" if rem == 1 else "0"))
    return "".join(digits)

def decode_balanced_ternary(s: str) -> int:
    total = 0
    power = 1
    for ch in s:
        if ch == "+":
            total = add_nand(total, power)
        elif ch == "-":
            total -= power
        power = add_nand(add_nand(power, power), power)
    return total

if __name__ == "__main__":
    assert balanced_ternary(0) == "0" and decode_balanced_ternary("0") == 0
    f_prev, f_curr = 0, 1
    strict_lsb_1_to_12 = []
    display_1_to_12 = []
    expected_f_1_to_12 = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
    for n in range(1, 40):
        bt = balanced_ternary(f_curr)
        assert decode_balanced_ternary(bt) == f_curr, f"Round-trip failed at n={n}"
        non_zero_marks = sum(1 for c in bt if c in ("-", "+"))
        assert (f_curr % 2 == 0) == (non_zero_marks % 2 == 0) == (n % 3 == 0), f"Parity law failed at n={n}"
        if n <= 12:
            lsb_padded = bt.ljust(3, "0")
            assert decode_balanced_ternary(lsb_padded) == expected_f_1_to_12[n - 1]
            strict_lsb_1_to_12.append(lsb_padded)
            display_1_to_12.append(bt.lstrip("0").rjust(3, "0") if len(bt) < 3 else bt)
        f_prev, f_curr = f_curr, add_nand(f_prev, f_curr)

    strict_lsb_out = " ".join(strict_lsb_1_to_12)
    strip_out = " ".join(display_1_to_12)
    assert strict_lsb_out == "+00 +00 -+0 0+0 --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+"
    assert [decode_balanced_ternary(t) for t in strict_lsb_out.split()] == expected_f_1_to_12
    assert strip_out == "00+ 00+ 0-+ 00+ --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+"
    print("Strict LSB-First Strip F(1..12):", strict_lsb_out, "-> decoded:", [decode_balanced_ternary(t) for t in strict_lsb_out.split()])
    print("Display Strip F(1..12):         ", strip_out)
    print("ALL 40 NAND-GATE & BALANCED-TERNARY PARITY ASSERTIONS PASSED [OK]")
