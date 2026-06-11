"""Composition root - the ONE place where modules meet.

@intent     Wire store + ledger + money into a runnable demo. Wiring ONLY:
            if logic appears here, it belongs in a module instead.
@flow       load entries (store) -> apply domain operations (ledger) ->
            save (store) -> present (money.fmt). Top to bottom, no branches
            of substance - composition roots should read like a recipe.
@boundary   The only module allowed to import everything. Nothing imports it.
@invariant  All I/O passes through adapters; all math through core. The root
            owns sequencing, never rules.
"""
from core import ledger, money
import store

LEDGER_PATH = "tab.json"


def main() -> None:
    entries = store.load(LEDGER_PATH)

    entries = ledger.add_entry(entries, who="sam", item="coffee", qty=2,
                               unit_cents=money.parse_cents("3.50"))
    entries = ledger.add_entry(entries, who="alex", item="bagel", qty=1,
                               unit_cents=money.parse_cents("2.75"))

    store.save(LEDGER_PATH, entries)

    print(f"tab total: {money.fmt(ledger.balance(entries))}")
    for who, cents in ledger.balance_by_person(entries).items():
        print(f"  {who}: {money.fmt(cents)}")


if __name__ == "__main__":
    main()
