# shellcheck shell=bash
# ── row 134 -- two instances of one kind declaration sharing a key are compared, BY NAME
#    (den-hoag-kind-generator-collision-d4gnx; ADR-0034, ADR-0022) ──
# A kind that composes a parent is a module keyed by its mark. One generator called twice builds two
# constructions with one mark, and imported side by side gen-merge's key dedup kept the first and
# dropped the second without a word: which one survived depended on import order. The kind now
# publishes its comparison beside the key (`__keyEq`), the one its ancestor map makes, so the pair is
# refused by name. The unplanted arm imports ONE construction twice and asserts a STDOUT VALUE, so a
# door that refused every repeated key cannot pass it; the two arms differ by the second call alone.
row134='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  str = default: merge.mkOption { type = merge.types.str; inherit default; };
  ferrule = x: (merge.evalModuleTree { } [
      { options.schema = schema.mkSchemaOption { }; }
      {
        config.schema.p.options.o_p = str "p";
        config.schema.a = { inherits = [ "p" ]; options.o_a = str x; };
      }
    ]).config.schema.a;
  read = modules: (merge.evalModuleTree { } modules).config.o_a;
  one = ferrule "one";
  green = read [ one one ];
  planted = read [ (ferrule "one") (ferrule "two") ];
  red = planted;
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row134 unplanted (one construction imported twice is one module)" \
  "${row134/BODY/green}" 0 "" "$tmpdir/row134-green.err" 'one'
check "T5 row134 planted   (two constructions sharing a key are refused by name)" \
  "${row134/BODY/red}" 1 \
  "gen-schema: kind 'a' is imported twice under one key: two declarations of 'a' mint one identity and are unequal only at sealed component(s) 'modules', 'open.options.o_a.default': a sealed component is compared by its seal, the whole value under Nix \`==\`, where two separately built functions are never equal, so two separate constructions are refused even where the values they compute are equal" \
  "$tmpdir/row134-red.err"
check "T5 row134 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row134/BODY/caught}" 0 "" "$tmpdir/row134-catch.err" 'CAUGHT'
