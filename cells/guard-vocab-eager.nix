# `guard-vocab-eager` — C31, den-hoag-cr72. A custom guard form missing `reads`, and one shadowing
# the core `eq` form, each still CONSTRUCT a vocabulary and each refuse on its first `applyGuard`
# call, though that call dispatches `always` and never names the bad form. A sound invented form
# (`fourchette`) constructs and dispatches beside them, so the refusals are not `applyGuard`
# refusing everything.
#
# C31 — ADR-0025 item 1 in gen-aspects' guard vocabulary (den-hoag-cr72): a
# malformed or core-colliding custom form is a NAMED refusal at the vocabulary's
# first use, not a value that travels until something happens to dispatch it by name.
{
  asserts,
  cr72Constructs,
  cr72Dispatch,
  cr72NoReads,
  cr72Refuses,
  cr72Sound,
  cr72Vocab,
}:
{
  construct = [ "C31" ];
  check = asserts (
    # (1) CONTROL — a well-formed, non-colliding form constructs AND dispatches.
    # Without it the refusals below read as `applyGuard` refusing unconditionally.
    cr72Dispatch (cr72Vocab {
      fourchette = cr72Sound;
    }) == {
      fired = true;
    }
    # (2) a `fourchette` form missing `reads`. Construction stays TOTAL — the fix
    # deliberately does NOT move the throw onto `mkGuardVocab`'s return, because that
    # makes the return's WHNF depend on `guardForms`' key set and cycles for a caller
    # whose key comes from its own config fixpoint (den-hoag-fvxh's shape) ...
    && cr72Constructs (cr72Vocab {
      fourchette = cr72NoReads;
    })
    # ... and the FIRST `applyGuard` call through that vocab refuses, though it
    # dispatches `always` and never names `fourchette`.
    && cr72Refuses (
      cr72Dispatch (cr72Vocab {
        fourchette = cr72NoReads;
      })
    )
    # (3) a custom form shadowing the core `eq` form — same corrected shape.
    && cr72Constructs (cr72Vocab {
      eq = cr72Sound;
    })
    && cr72Refuses (
      cr72Dispatch (cr72Vocab {
        eq = cr72Sound;
      })
    )
  );
}
