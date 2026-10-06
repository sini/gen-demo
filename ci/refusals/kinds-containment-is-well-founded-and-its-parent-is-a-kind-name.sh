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
row_kinds_containment_is_well_founded_and_its_parent_is_a_kind_name='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  schema = kinds: (genMerge.evalModuleTree { } [
    { options.schema = genSchema.mkSchemaOption { }; }
    { config.schema = kinds; }
  ]).config.schema;
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
check "T5 kinds-containment-is-well-founded-and-its-parent-is-a-kind-name unplanted (a well-founded hierarchy with string parents answers its roots and leaves)" \
  "${row_kinds_containment_is_well_founded_and_its_parent_is_a_kind_name/BODY/acyclic}" 0 "" "$tmpdir/kinds-containment-is-well-founded-and-its-parent-is-a-kind-name-green.err" 'loom,|,heddle'
check "T5 kinds-containment-is-well-founded-and-its-parent-is-a-kind-name planted   (two kinds that parent each other are refused, naming both)" \
  "${row_kinds_containment_is_well_founded_and_its_parent_is_a_kind_name/BODY/cycle}" 1 \
  'gen-schema: containment cycle among kinds [frame heddle] — a kind may not be its own ancestor' "$tmpdir/kinds-containment-is-well-founded-and-its-parent-is-a-kind-name-red.err"
check "T5 kinds-containment-is-well-founded-and-its-parent-is-a-kind-name planted   (a kind that parents itself is refused, naming it)" \
  "${row_kinds_containment_is_well_founded_and_its_parent_is_a_kind_name/BODY/self}" 1 \
  'gen-schema: containment cycle among kinds [frame] — a kind may not be its own ancestor' "$tmpdir/kinds-containment-is-well-founded-and-its-parent-is-a-kind-name-self.err"
check "T5 kinds-containment-is-well-founded-and-its-parent-is-a-kind-name planted   (a parent that is not a kind name is refused, naming the kind and the type)" \
  "${row_kinds_containment_is_well_founded_and_its_parent_is_a_kind_name/BODY/badParent}" 1 \
  "gen-schema: kind 'frame' declares a parent of type int, not a kind name" "$tmpdir/kinds-containment-is-well-founded-and-its-parent-is-a-kind-name-type.err"
check "T5 kinds-containment-is-well-founded-and-its-parent-is-a-kind-name catchable  (the cycle refusal is caught by tryEval, not an abort)" \
  "${row_kinds_containment_is_well_founded_and_its_parent_is_a_kind_name/BODY/cycleCaught}" 0 "" "$tmpdir/kinds-containment-is-well-founded-and-its-parent-is-a-kind-name-catch.err" 'CAUGHT'
check "T5 kinds-containment-is-well-founded-and-its-parent-is-a-kind-name catchable  (the parent-type refusal is caught by tryEval, not an abort)" \
  "${row_kinds_containment_is_well_founded_and_its_parent_is_a_kind_name/BODY/badParentCaught}" 0 "" "$tmpdir/kinds-containment-is-well-founded-and-its-parent-is-a-kind-name-catch2.err" 'CAUGHT'
