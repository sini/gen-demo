# shellcheck shell=bash
# ── row 89 -- an ENTITY of a sealed-only kind collision, refused by name at `sel.entity`'s
#    `selectorEq` (den-hoag-l0y (β); ADR-0034) ──
# Row 82's two `selvage` kinds (differing only in a refinement predicate, a caller lambda, so the
# field is sealed) mint ONE mark, so one `bolt` instance of each, at equal keys, carries ONE stamp.
# `kindEq` refuses the kinds by name (row 82); `sel.entity kind entry` now refuses the entities the
# same way, where it used to call them equal on the stamp alone. The unplanted arm compares an entity
# with itself; the premise arm shows the two stamps ARE equal, so the planted refusal is decided at an
# equal stamp and not by a stamp difference. Every addressing is bound here, in the prelude.
row89='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  sel = gen.lib.substrate.select;
  merge = gen.lib.modules.merge;
  selvage = r: (merge.evalModuleTree { modules = [
    { options.schema = schema.mkSchemaOption { }; }
    { config.schema.selvage.options.ends = merge.mkOption { type = schema.refined merge.types.int r; }; }
  ]; }).config.schema.selvage;
  ends = selvage schema.refinements.tcpPort;
  endsP = selvage schema.refinements.positive;
  bolt = k: (merge.evalModuleTree { modules = [
    { options.r = schema.mkInstanceRegistry k { }; config.r.bolt.ends = 443; }
  ]; }).config.r.bolt;
  a = bolt ends;
  b = bolt endsP;
  stampsEqual = a.id_hash == b.id_hash;
  unplanted = sel.selectorEq (sel.entity ends a) (sel.entity ends a);
  planted = sel.selectorEq (sel.entity ends a) (sel.entity endsP b);
in BODY'
check "T5 row89 premise   (the two entities carry one stamp)" \
  "${row89/BODY/builtins.toJSON stampsEqual}" 0 "" "$tmpdir/row89-premise.err" 'true'
check "T5 row89 unplanted (an entity compared with itself is one entity)" \
  "${row89/BODY/builtins.toJSON unplanted}" 0 "" "$tmpdir/row89-green.err" 'true'
check "T5 row89 planted   (two entities of kinds differing only at a sealed field, refused by name)" \
  "${row89/BODY/builtins.toJSON planted}" 1 \
  "gen-select: selectorEq: two declarations of 'selvage' mint one identity and differ, compared as values, only at sealed component(s) 'options.ends.type'" \
  "$tmpdir/row89-red.err"
check "T5 row89 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row89/BODY/if (builtins.tryEval planted).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row89-catch.err" 'CAUGHT'
