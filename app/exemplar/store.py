"""Durable JSON store - an adapter module at the effectful boundary.

@intent     Own ALL filesystem contact for the exemplar. The pure core never
            touches disk; this is the only module allowed to.
@flow       load: path -> JSON -> entries list (empty if absent).
            save: entries -> temp file -> fsync -> atomic rename over target.
@boundary   Depends on: stdlib (json, os, tempfile) - NO core imports; adapters
            move bytes, they do not know domain rules. Depended on by: app only.
@invariant  Durable writes: a crash at ANY instant leaves either the old complete
            file or the new complete file - never a torn half-write. This is the
            kit's durability law in its smallest possible implementation.
@risk       Concurrent writers are out of scope (single-process demo). A real
            store adds locking or a transactional engine - the INTERFACE stays.
"""
import json
import os
import tempfile


def load(path: str) -> list:
    """Missing file = empty ledger (first run is not an error)."""
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save(path: str, entries: list) -> None:
    """Atomic write: temp file in the SAME directory (rename across filesystems
    is not atomic), flush + fsync (durability), then rename (atomicity)."""
    directory = os.path.dirname(os.path.abspath(path)) or "."
    fd, tmp = tempfile.mkstemp(dir=directory, suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            json.dump(entries, f, indent=1)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp, path)  # atomic on POSIX and Windows
    except BaseException:
        if os.path.exists(tmp):
            os.unlink(tmp)
        raise
