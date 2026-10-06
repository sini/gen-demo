# shellcheck shell=bash
# ── row 146 -- a value cycle between two gen-aspects trees is refused by name, catchably
#    (den-hoag-24zdh; ADR-0025 item 1) ──
# gen-aspects builds its kinds with a caller `mkType`, whose result reads its `defs`. Two aspect
# trees whose `aspect` inherits the other's are a value cycle on that arm. Before den-hoag-24zdh the
# caller's `defs` carried one def per composed parent, so their shape read each parent's
# classification, each kind's value forced its partner's, and every evaluator aborted uncatchably.
# The desugared parents now reach the caller as one def, and the cycle is refused under `aspect`'s
# name. The unplanted arm gives the second tree a fresh parent instead and asserts the composed
# option names on STDOUT, the parent's included: that is the arm that reds if the desugared def
# stops reaching gen-aspects' `defs`. Addressing as row 12, through `gen.lib.aspects.aspects`.
row_value_cycle_between_two_gen_aspects_trees='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  int = merge.mkOption { type = merge.types.int; };
  schema = genAspects.mkAspectSchema { };
  tree = modules: (merge.evalModuleTree { } ([ { options.schema = schema.schemaOption; } ] ++ modules)).config.schema;
  aspect = parent: o: { config.schema.aspect = { inherits = [ parent ]; options.${o} = int; }; };
  pairWith = bParent: let
    tA = tree [ (aspect tB.aspect "warp") ];
    tB = tree [ (aspect (bParent tA.aspect) "weft") ];
  in tA.aspect;
  fresh = (tree [ { config.schema.aspect.options.selvage = int; } ]).aspect;
  opts = k: builtins.concatStringsSep " " (builtins.attrNames k.options);
  green = opts (pairWith (_: fresh));
  red = opts (pairWith (a: a));
  caught = if (builtins.tryEval (builtins.deepSeq (pairWith (a: a)).options null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 value-cycle-between-two-gen-aspects-trees unplanted (the second tree inherits a fresh aspect: the first composes all three options)" \
  "${row_value_cycle_between_two_gen_aspects_trees/BODY/green}" 0 "" "$tmpdir/value-cycle-between-two-gen-aspects-trees-green.err" 'selvage warp weft'
check "T5 value-cycle-between-two-gen-aspects-trees planted   (two aspect trees inherit each other: refused by the aspect kind's name)" \
  "${row_value_cycle_between_two_gen_aspects_trees/BODY/red}" 1 \
  "gen-schema: kind 'aspect' reaches a kind with its own content witness through its parents (aspect -> aspect -> aspect), among kinds [aspect]" \
  "$tmpdir/value-cycle-between-two-gen-aspects-trees-red.err"
check "T5 value-cycle-between-two-gen-aspects-trees catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_value_cycle_between_two_gen_aspects_trees/BODY/caught}" 0 "" "$tmpdir/value-cycle-between-two-gen-aspects-trees-catch.err" 'CAUGHT'
