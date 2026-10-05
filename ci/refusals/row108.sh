# shellcheck shell=bash
# ── row 108 -- `_identity` is a closed record: a key other than `keys` is refused BY NAME, and a
#    module-shaped definition is refused at the leaf's domain, both catchably, at gen-schema's
#    `mkIdentityModule` (den-hoag-xzchx arm 4; ADR-0025 item 1) ──
# `_identity` is one `lazyAttrsOf (listOf str)` leaf whose `apply` closes it to `keys`, not a
# nested submodule. A misspelt key refuses naming itself, under `mkIf false` too (an `attrsOf` fold
# would drop that key before `apply` saw it); a function definition is outside the leaf's domain.
# The unplanted arm asserts a STDOUT VALUE -- duplicate keys dedup to the same identity -- so a
# door that refused everything cannot pass it. Every addressing is bound in the prelude: a `}`
# inside a `${row108/BODY/...}` replacement would end the expansion early.
row108='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  kinds = schema.evalSchema { } [
      {
        config.schema.aglet.options.finish = merge.mkOption { type = merge.types.str; };
        config.schema.aglet.options.gauge = merge.mkOption { type = merge.types.str; };
      }
    ];
  hashOf = identity: (merge.evalModuleTree { } [
      {
        options.aglets = schema.mkInstanceRegistry { } kinds.aglet;
        config.aglets.gilt = {
          finish = "gilded";
          gauge = "fine";
          _identity = identity;
        };
      }
    ]).config.aglets.gilt.id_hash;
  green = if hashOf { keys = [ "finish" ]; } == hashOf { keys = [ "finish" "finish" ]; } then "EQUAL" else "DISTINCT";
  foreign = hashOf { bogus = [ "finish" ]; };
  foreignIfFalse = hashOf { keys = [ "finish" ]; bogus = merge.mkIf false [ "finish" ]; };
  fn = hashOf ({ config, ... }: { keys = [ "finish" ]; });
  caughtOf = e: if (builtins.tryEval e).success then "ADMITTED" else "CAUGHT";
  caught = "${caughtOf foreign} ${caughtOf foreignIfFalse} ${caughtOf fn}";
in BODY'
check "T5 row108 unplanted (duplicate identity keys dedup to one identity)" \
  "${row108/BODY/green}" 0 "" "$tmpdir/row108-green.err" 'EQUAL'
check "T5 row108 planted   (a foreign _identity key is refused naming the closed record)" \
  "${row108/BODY/foreign}" 1 \
  "gen-schema: \`_identity' declares only \`keys'; it does not declare \`bogus'" \
  "$tmpdir/row108-foreign.err"
check "T5 row108 planted   (a foreign _identity key under mkIf false is refused, not dropped)" \
  "${row108/BODY/foreignIfFalse}" 1 \
  "gen-schema: \`_identity' declares only \`keys'; it does not declare \`bogus'" \
  "$tmpdir/row108-foreign-if-false.err"
check "T5 row108 planted   (a function _identity definition is refused at the leaf's domain)" \
  "${row108/BODY/fn}" 1 \
  "gen-merge: option \`aglets.gilt._identity' has definitions \`lazyAttrsOf' cannot consume" \
  "$tmpdir/row108-fn.err"
check "T5 row108 catchable  (every refusal is caught by tryEval, not an abort)" \
  "${row108/BODY/caught}" 0 "" "$tmpdir/row108-catch.err" 'CAUGHT CAUGHT CAUGHT'
