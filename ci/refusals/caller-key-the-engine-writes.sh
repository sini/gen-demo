# shellcheck shell=bash
# ── row 105 -- a caller key the engine writes over is refused BY NAME, catchably, not discarded
#    (den-hoag-v9gjd; C29) ──
# C29's `bobbin` kind through `evalSchema`, with `config` planted in `specialArgs` beside `argand`.
# gen-merge injects its own `config`, `options` and `prefix` over the caller's set, so the planted
# key reached no module and the kind read `gimp` exactly as unplanted. The engine now refuses it
# and names the key. The unplanted arm asserts a STDOUT VALUE, `argand`'s, so an engine that
# refused every `specialArgs` cannot pass it. Every addressing is bound in the prelude: a `}`
# inside a `${row105/BODY/...}` replacement would end the expansion early.
row_caller_key_the_engine_writes='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  selvageWith = extra: (schema.evalSchema { specialArgs = { argand.selvage = "gimp"; } // extra; } [
      {
        config.schema.bobbin.imports = [
          ({ argand, ... }: {
            options.selvage = merge.mkOption { type = merge.types.str; default = argand.selvage; };
          })
        ];
      }
    ]).bobbin.options.selvage.default;
  green = selvageWith { };
  red = selvageWith { config = "CALLER"; };
  caught = if (builtins.tryEval red).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 caller-key-the-engine-writes unplanted (argand alone reaches the kind module)" \
  "${row_caller_key_the_engine_writes/BODY/green}" 0 "" "$tmpdir/caller-key-the-engine-writes-green.err" 'gimp'
check "T5 caller-key-the-engine-writes planted   (a caller config beside argand is refused by name)" \
  "${row_caller_key_the_engine_writes/BODY/red}" 1 \
  "gen-merge: \`specialArgs' cannot supply the base module argument \`config'; the engine injects its own value there" \
  "$tmpdir/caller-key-the-engine-writes-red.err"
check "T5 caller-key-the-engine-writes catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_caller_key_the_engine_writes/BODY/caught}" 0 "" "$tmpdir/caller-key-the-engine-writes-catch.err" 'CAUGHT'
