# shellcheck shell=bash
# ── row 98 -- strict mode names the undeclared KEY, and its printed remedy is the one that works
#    (den-hoag-0y9nr; ADR-0025 item 1) ──
# A strict kind's freeform type is merged at the instance's level, so the refusal used to name the
# INSTANCE (`instancePewter`) and print a remedy declaring an option of that name, which changed
# nothing. The unplanted arm declares exactly what the planted arm's `Fix:` line prints and asserts
# a STDOUT VALUE carrying the key, so a refusal whose remedy does not work cannot pass beside it. The
# planted arm is two checks, one per message line: a wanted string holding a newline is a set of
# alternatives to `grep -F`. The first stops before the defining-file clause, which names gen-merge's
# anonymous-module token rather than anything strict decides.
row98='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  gauge = merge.mkOption { type = merge.types.int; };
  thimble = extra: (merge.evalModuleTree { modules = [
    { options.schema = schema.mkSchemaOption { }; }
    { config.schema.thimble.options.declaredGauge = gauge; }
  ] ++ extra; }).config.schema.thimble;
  bolt = extra: (merge.evalModuleTree { modules = [
    { options.bolts = schema.mkInstanceRegistry (thimble extra) { }; }
    { config.bolts.instancePewter = { declaredGauge = 3; undeclaredWelt = 5; }; }
  ]; }).config.bolts.instancePewter;
  planted = bolt [ ];
  remedied = bolt [ { config.schema.thimble.options.undeclaredWelt = gauge; } ];
  unplanted = builtins.toJSON [ remedied.declaredGauge remedied.undeclaredWelt ];
  refused = builtins.toJSON planted.undeclaredWelt;
  caught = if (builtins.tryEval (builtins.deepSeq planted true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row98 unplanted (the printed remedy applied, the key reads back)" \
  "${row98/BODY/unplanted}" 0 "" "$tmpdir/row98-green.err" '[3,5]'
check "T5 row98 planted   (an undeclared key is named, at the instance)" \
  "${row98/BODY/refused}" 1 \
  'STRICT MODE: "undeclaredWelt" is not declared on thimble (instance at bolts.instancePewter' \
  "$tmpdir/row98-red.err"
check "T5 row98 remedy    (the refusal prints the remedy that declares the key)" \
  "${row98/BODY/refused}" 1 \
  'Fix: schema.thimble.options.undeclaredWelt = mkOption { ... };' \
  "$tmpdir/row98-fix.err"
check "T5 row98 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row98/BODY/caught}" 0 "" "$tmpdir/row98-catch.err" 'CAUGHT'
