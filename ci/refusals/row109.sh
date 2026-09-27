# shellcheck shell=bash
# ── row 109 -- an unknown option on gen-schema's `mkMixin` door is refused BY NAME, catchably
#    (den-hoag-7gp66 P1; ADR-0025 item 1) ──
# Before P1, `mkMixin`'s native closed formal (`{ define, requires ? [], provides ? [], kinds ?
# null, name ? null }:`) aborted UNCATCHABLY on an argument outside that set -- not even
# `builtins.tryEval` could see it. The door now takes a bare formal and applies gen-prelude's
# `checkOptions` over `checkRequired`'s result, so the same violation is NAMED and CATCHABLE. The
# unplanted arm builds a mixin from only its accepted options; the planted arm adds one the door
# does not declare.
row109='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  build =
    extra:
    schema.mkMixin (
      {
        define = _parent: { metrics_port = 9090; };
        provides = [ "metrics_port" ];
      }
      // extra
    );
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
