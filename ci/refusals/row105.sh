# shellcheck shell=bash
# ── row 105 -- a caller key the engine writes over is refused BY NAME, catchably, not discarded
#    (den-hoag-v9gjd; C29) ──
# C29's `bobbin` kind through `evalSchema`, with `config` planted in `specialArgs` beside `argand`.
# gen-merge injects its own `config`, `options` and `prefix` over the caller's set, so the planted
# key reached no module and the kind read `gimp` exactly as unplanted. The engine now refuses it
# and names the key. The unplanted arm asserts a STDOUT VALUE, `argand`'s, so an engine that
# refused every `specialArgs` cannot pass it. Every addressing is bound in the prelude: a `}`
# inside a `${row105/BODY/...}` replacement would end the expansion early.
row105='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  selvageWith = extra: (schema.evalSchema {
    modules = [
      {
        config.schema.bobbin.imports = [
          ({ argand, ... }: {
            options.selvage = merge.mkOption { type = merge.types.str; default = argand.selvage; };
          })
        ];
      }
    ];
    specialArgs = { argand.selvage = "gimp"; } // extra;
  }).bobbin.options.selvage.default;
  green = selvageWith { };
  red = selvageWith { config = "CALLER"; };
  caught = if (builtins.tryEval red).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row105 unplanted (argand alone reaches the kind module)" \
  "${row105/BODY/green}" 0 "" "$tmpdir/row105-green.err" 'gimp'
check "T5 row105 planted   (a caller config beside argand is refused by name)" \
  "${row105/BODY/red}" 1 \
  "gen-merge: \`specialArgs' cannot supply the base module argument \`config'; the engine injects its own value there" \
  "$tmpdir/row105-red.err"
check "T5 row105 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row105/BODY/caught}" 0 "" "$tmpdir/row105-catch.err" 'CAUGHT'
