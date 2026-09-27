# shellcheck shell=bash
# ── row 107 -- a declaration value that is not the registry's member is refused BY NAME, catchably,
#    at gen-schema's `declarationOf` (den-hoag-a4158; den-hoag-2zjg1 arm (B); ADR-0025 item 1) ──
# A value handed to `declarationOf` resolves to the registry's entry only if it IS that entry: it
# carries the member's stamp and the member's identity-key values. The key-override idiom
# `gilt // { finish = "tarnished"; }` keeps the stamp while the key moves, and was admitted and
# served its own edit. The unplanted arm hands the member itself and asserts a STDOUT VALUE, so a
# door that refused everything cannot pass it; the two arms differ by the `//` alone. Every
# addressing is bound in the prelude: a `}` inside a `${row107/BODY/...}` replacement would end the
# expansion early.
row107='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  kinds = schema.evalSchema {
    modules = [
      {
        config.schema.aglet.options.finish = merge.mkOption { type = merge.types.str; };
        config.schema.lacet.options.tip = merge.mkOption { type = schema.declarationOf "aglet"; };
      }
    ];
  };
  tipOf = pick: (merge.evalModuleTree {
    modules = [
      ({ config, ... }: {
        options.aglets = schema.mkInstanceRegistry kinds.aglet { };
        options.lacets = schema.mkInstanceRegistry kinds.lacet { refs.tip = config.aglets; };
        config.aglets.gilt.finish = "gilded";
        config.lacets.l.tip = pick config.aglets.gilt;
      })
    ];
  }).config.lacets.l.tip.finish;
  green = tipOf (g: g);
  planted = tipOf (g: g // { finish = "tarnished"; });
  red = planted;
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row107 unplanted (the member itself resolves to its entry)" \
  "${row107/BODY/green}" 0 "" "$tmpdir/row107-green.err" 'gilded'
check "T5 row107 planted   (a key-overridden member is refused as a non-member)" \
  "${row107/BODY/red}" 1 \
  "ref field 'tip' on kind 'lacet': declaration 'gilt' is not a member of the registry (available: 'gilt')" \
  "$tmpdir/row107-red.err"
check "T5 row107 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row107/BODY/caught}" 0 "" "$tmpdir/row107-catch.err" 'CAUGHT'
