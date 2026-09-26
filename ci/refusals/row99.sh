# shellcheck shell=bash
# ── row 99 -- a kind's containment is WELL-FOUNDED and its `parent` is a kind NAME, both refused BY
#    NAME, catchably (den-hoag-4bqim, den-hoag-jvcgq; ADR-0025 item 1) ──
# A kind that is its own ancestor was admitted SILENTLY: `frame` and `heddle` parenting each other
# read `_roots` = ["loom"] with exit 0, both kinds missing from `_roots` and `_leaves` and nothing
# said. A `parent` that is not a string aborted with an interpreter error that `tryEval` cannot
# catch. The unplanted arm is a real three-level hierarchy and asserts its roots and leaves, so a
# topology that refused everything cannot pass it; the planted arms name the cycle's members, and
# the kind with its parent's type. Every addressing is bound in the prelude: a `}` inside a
# `${row99/BODY/...}` replacement would end the expansion early.
row99='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  schema = kinds: (genMerge.evalModuleTree { modules = [
    { options.schema = genSchema.mkSchemaOption { }; }
    { config.schema = kinds; }
  ]; }).config.schema;
  nested = schema { loom = { }; frame.parent = "loom"; heddle.parent = "frame"; };
  looped = schema { loom = { }; frame.parent = "heddle"; heddle.parent = "frame"; };
  selfed = schema { loom = { }; frame.parent = "frame"; };
  malformed = schema { loom = { }; frame.parent = 5; };
  caught = x: if (builtins.tryEval (builtins.deepSeq x null)).success then "ADMITTED" else "CAUGHT";
  acyclic = builtins.concatStringsSep "," (nested._roots ++ [ "|" ] ++ nested._leaves);
  cycle = builtins.toJSON looped._roots;
  self = builtins.toJSON selfed._leaves;
  badParent = builtins.toJSON malformed._roots;
  cycleCaught = caught looped._roots;
  badParentCaught = caught malformed._roots;
in BODY'
check "T5 row99 unplanted (a well-founded hierarchy with string parents answers its roots and leaves)" \
  "${row99/BODY/acyclic}" 0 "" "$tmpdir/row99-green.err" 'loom,|,heddle'
check "T5 row99 planted   (two kinds that parent each other are refused, naming both)" \
  "${row99/BODY/cycle}" 1 \
  'gen-schema: containment cycle among kinds [frame heddle] — a kind may not be its own ancestor' "$tmpdir/row99-red.err"
check "T5 row99 planted   (a kind that parents itself is refused, naming it)" \
  "${row99/BODY/self}" 1 \
  'gen-schema: containment cycle among kinds [frame] — a kind may not be its own ancestor' "$tmpdir/row99-self.err"
check "T5 row99 planted   (a parent that is not a kind name is refused, naming the kind and the type)" \
  "${row99/BODY/badParent}" 1 \
  "gen-schema: kind 'frame' declares a parent of type int, not a kind name" "$tmpdir/row99-type.err"
check "T5 row99 catchable  (the cycle refusal is caught by tryEval, not an abort)" \
  "${row99/BODY/cycleCaught}" 0 "" "$tmpdir/row99-catch.err" 'CAUGHT'
check "T5 row99 catchable  (the parent-type refusal is caught by tryEval, not an abort)" \
  "${row99/BODY/badParentCaught}" 0 "" "$tmpdir/row99-catch2.err" 'CAUGHT'
