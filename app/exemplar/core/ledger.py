"""Tab ledger domain logic - a pure core module with zero I/O.

@intent     Own the ledger rules: add entries, compute balances. Nothing else.
@flow       entries (list of dicts) -> validated new entry appended -> totals
            computed by summing integer cents. Data in, data out - this module
            could run unchanged in a browser, a server, or firmware.
@boundary   Depends on: core.money only. Depended on by: app (composition root).
            Knows NOTHING about storage, UI, or where entries come from.
@invariant  Entries are append-only here (corrections are new negative entries -
            an audit trail never rewrites history). Totals are exact (see money).
@todo       Multi-person tabs (split entries) when the demo needs teaching that.
"""
from .money import line_total


def add_entry(entries: list, who: str, item: str, qty: int, unit_cents: int) -> list:
    """Returns a NEW list with the entry appended - never mutates the input.
    Immutability keeps callers honest and tests trivial."""
    if qty <= 0:
        raise ValueError("qty must be positive - corrections are negative-priced entries")
    if not who or not item:
        raise ValueError("who and item are required")
    entry = {"who": who, "item": item, "qty": qty, "unit_cents": unit_cents,
             "total_cents": line_total(qty, unit_cents)}
    return [*entries, entry]


def balance(entries: list) -> int:
    """Sum of line totals, in cents. Round-per-line already happened at parse;
    summing integers cannot drift. (@invariant money: round THEN sum.)"""
    return sum(e["total_cents"] for e in entries)


def balance_by_person(entries: list) -> dict:
    """who -> cents owed. Pure aggregation; presentation/formatting is NOT
    this module's job (see @boundary - no fmt() calls in domain logic)."""
    out: dict = {}
    for e in entries:
        out[e["who"]] = out.get(e["who"], 0) + e["total_cents"]
    return out
