# shellcheck shell=bash
# ── row 109 -- an unknown option on gen-schema's `mkMixin` door is refused BY NAME, catchably
#    (den-hoag-7gp66 P1; ADR-0025 item 1) ──
# Before P1, `mkMixin`'s native closed formal (`{ define, requires ? [], provides ? [], kinds ?
# null, name ? null }:`) aborted UNCATCHABLY on an argument outside that set -- not even
# `builtins.tryEval` could see it. After P2 L4 the options are one closed `prelude.door` set, first
# in the call, and `define` is the operand after it, so the same violation is NAMED and CATCHABLE at
# the options application. The unplanted arm builds a mixin from only its accepted options; the
# planted arm adds one the door does not declare.
row109='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  build =
    extra:
    schema.mkMixin ({ provides = [ "metrics_port" ]; } // extra) (_parent: { metrics_port = 9090; });
  green = if (build { }) ? __isMixin then "MIXIN" else "NOT-A-MIXIN";
  red = build { bogus = 1; };
  caught = if (builtins.tryEval (build { bogus = 1; })).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row109 unplanted (a mixin door given only its accepted options constructs)" \
  "${row109/BODY/green}" 0 "" "$tmpdir/row109-green.err" 'MIXIN'
check "T5 row109 planted   (an unknown option on gen-schema's mkMixin door is refused BY NAME, den-hoag-7gp66 P1)" \
  "${row109/BODY/red}" 1 \
  "gen-schema.mkMixin: 'bogus' is not an option of this door; the options are closed" \
  "$tmpdir/row109-red.err"
check "T5 row109 catchable  (the refusal is caught by tryEval, not an uncatchable formal-mismatch abort)" \
  "${row109/BODY/caught}" 0 "" "$tmpdir/row109-catch.err" 'CAUGHT'
