"""Mirrored tests - exhaustive for the pure core, contract test for the adapter.

@intent     Demonstrate the testing convention: every module has a mirror here;
            pure modules get edge-case coverage (cheap), adapters get a contract
            test proving their @invariant (here: atomic durability survives use).
"""
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core import ledger, money  # noqa: E402
import store  # noqa: E402


class TestMoney(unittest.TestCase):
    def test_parse_exact(self):
        self.assertEqual(money.parse_cents("12.34"), 1234)
        self.assertEqual(money.parse_cents("0.05"), 5)
        self.assertEqual(money.parse_cents("7"), 700)
        self.assertEqual(money.parse_cents("7.5"), 750)
        self.assertEqual(money.parse_cents("-3.50"), -350)

    def test_parse_rejects_garbage(self):
        for bad in ["", "1.234", "1.2.3", "abc", "$5", "1,000.00"]:
            with self.assertRaises(ValueError, msg=bad):
                money.parse_cents(bad)

    def test_round_then_sum_never_drifts(self):
        # The classic float bug: 0.1 + 0.2 != 0.3. In cents it cannot happen.
        total = sum(money.parse_cents(x) for x in ["0.10", "0.20"])
        self.assertEqual(total, money.parse_cents("0.30"))

    def test_fmt(self):
        self.assertEqual(money.fmt(1234), "12.34")
        self.assertEqual(money.fmt(5), "0.05")
        self.assertEqual(money.fmt(-350), "-3.50")


class TestLedger(unittest.TestCase):
    def test_append_is_immutable(self):
        first = ledger.add_entry([], "sam", "coffee", 2, 350)
        second = ledger.add_entry(first, "alex", "bagel", 1, 275)
        self.assertEqual(len(first), 1)   # original untouched
        self.assertEqual(len(second), 2)

    def test_balances(self):
        e = ledger.add_entry([], "sam", "coffee", 2, 350)
        e = ledger.add_entry(e, "alex", "bagel", 1, 275)
        self.assertEqual(ledger.balance(e), 975)
        self.assertEqual(ledger.balance_by_person(e), {"sam": 700, "alex": 275})

    def test_validation(self):
        with self.assertRaises(ValueError):
            ledger.add_entry([], "sam", "coffee", 0, 350)
        with self.assertRaises(ValueError):
            ledger.add_entry([], "", "coffee", 1, 350)


class TestStoreContract(unittest.TestCase):
    def test_round_trip_and_missing_file(self):
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "tab.json")
            self.assertEqual(store.load(path), [])          # first run = empty
            entries = ledger.add_entry([], "sam", "coffee", 2, 350)
            store.save(path, entries)
            self.assertEqual(store.load(path), entries)      # durable round trip
            # no stray temp files left behind (atomicity hygiene)
            self.assertEqual([f for f in os.listdir(d) if f.endswith(".tmp")], [])


if __name__ == "__main__":
    unittest.main()
