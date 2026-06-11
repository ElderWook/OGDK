# Exemplar — the annotated-code quality bar

This is NOT a starter app. It is the kit's canonical demonstration of
`docs-template/CODE-CONVENTIONS.md`: every generated skeleton, in any language,
should look and feel like this — annotated headers, pure core, effectful shell,
one composition root, mirrored tests. ~120 lines total; read it in five minutes.

What it demonstrates (a deliberately tiny "tab ledger"):

```
core/money.py    pure module     @invariant exact integer cents, no floats ever
core/ledger.py   pure module     @flow domain logic with zero I/O
store.py         adapter         @boundary durable atomic writes (temp + rename)
app.py           composition     wiring ONLY — the one place modules meet
tests/           mirrored tests  exhaustive for the pure core, contract for the adapter
```

Flow at runtime: `app.py` wires store → ledger; `ledger` computes purely; `money`
guards precision; `store` is the only file that touches the filesystem.

Run it (pure Python, zero dependencies):

```
python -m unittest discover app/exemplar/tests     # from the kit root
python app/exemplar/app.py                         # tiny demo run
```

The pattern scales: the origin app is this exemplar's shape grown to production —
core/ became a full domain layer, store.py became SQLite with migrations, app.py
became per-surface composition roots. The shape never changed.
