"""Exact money arithmetic - the kit's precision invariant, demonstrated.

@intent     Own ALL money math so no other module ever touches a float for
            currency. One module, one concern: cents in, cents out, exactly.
@flow       dollars-as-text -> integer cents -> arithmetic in cents -> formatted text.
            Rounding happens in exactly one place (parse) and nowhere else.
@boundary   Depends on: nothing (stdlib only - pure core).
            Depended on by: ledger (and anything priced). Never imports siblings.
@invariant  Money is integer minor-units end-to-end. Round per line THEN sum -
            never sum floats and round once (that is how pennies vanish).
@risk       Locale formatting (1.234,56) is deliberately out of scope; parse
            accepts plain "1234.56" strings only. Revisit if i18n ever lands.
"""


def parse_cents(text: str) -> int:
    """'12.34' -> 1234. The ONLY place rounding may occur.

    Accepts an optional leading '-', digits, optional '.' with up to 2 decimals.
    Raises ValueError on anything else - bad money input is never coerced.
    """
    text = text.strip()
    negative = text.startswith("-")
    if negative:
        text = text[1:]
    if not text or text.count(".") > 1:
        raise ValueError(f"not a money amount: {text!r}")
    whole, _, frac = text.partition(".")
    if not whole.isdigit() or (frac and not frac.isdigit()) or len(frac) > 2:
        raise ValueError(f"not a money amount: {text!r}")
    cents = int(whole) * 100 + int(frac.ljust(2, "0") or 0)
    return -cents if negative else cents


def line_total(qty: int, unit_cents: int) -> int:
    """qty x unit price, in cents. Pure multiplication - no rounding needed,
    because we never left integers. That is the whole point."""
    return qty * unit_cents


def fmt(cents: int) -> str:
    """1234 -> '12.34'. Presentation only; never parsed back by machines."""
    sign = "-" if cents < 0 else ""
    cents = abs(cents)
    return f"{sign}{cents // 100}.{cents % 100:02d}"
