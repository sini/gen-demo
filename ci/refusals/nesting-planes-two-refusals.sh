# shellcheck shell=bash
# ── row 119 -- the nesting plane's two refusals, BY NAME, with the door and the option (C103,
#    den-hoag-tn3qf; OQ1 arm (ii-a), OQ2 arm (b), defaulted) ──
# C103's cell holds that each is caught; tryEval cannot read which throw it caught, so the name is
# read here. A nixpkgs `listOf` over a gen submodule stripped of its `nestedTypes` states no element
# and its payload OFFERS one; a `listOf str` stating a gen submodule in `nestedTypes` merges on one
# element and carries another. The unplanted arm states the element at the top level and serves a
# value, so a door that refused every such record cannot pass it.
row_nesting_planes_two_refusals='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  merge = gen.lib.modules.merge;
  t = gen.inputs.nixpkgs.lib.types;
  bobbin = merge.types.submodule { options.turns = merge.mkOption { type = merge.types.int; default = 0; }; };
  read = ty: v: (merge.evalModuleTree { } [ { options.skein = merge.mkOption { type = ty; }; } { config.skein = v; } ]).config.skein;
  topOnly = (builtins.removeAttrs (t.listOf bobbin) [ "nestedTypes" ]) // { elemType = bobbin; };
  green = builtins.toJSON (read topOnly [ { turns = 3; } ]);
  offered = builtins.deepSeq (read (t.listOf bobbin // { nestedTypes = { }; }) [ { turns = 3; } ]) "SERVED";
  disagree = builtins.deepSeq (read (t.listOf t.str // { nestedTypes.elemType = bobbin; }) [ "a" ]) "SERVED";
  caught = if (builtins.tryEval offered).success || (builtins.tryEval disagree).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 nesting-planes-two-refusals unplanted (the element stated at the top level threads as gen's listOf)" \
  "${row_nesting_planes_two_refusals/BODY/green}" 0 "" "$tmpdir/nesting-planes-two-refusals-green.err" '[{"turns":3}]'
check "T5 nesting-planes-two-refusals planted   (a payload-only offer of a nesting element is refused by name)" \
  "${row_nesting_planes_two_refusals/BODY/offered}" 1 \
  "gen-merge: \`evalModuleTree' at option \`skein': the option type \`listOf' offers a type declaring a gen nesting type to merge on" \
  "$tmpdir/nesting-planes-two-refusals-offer.err"
check "T5 nesting-planes-two-refusals planted   (a container whose two elements disagree is refused by name)" \
  "${row_nesting_planes_two_refusals/BODY/disagree}" 1 \
  "gen-merge: \`evalModuleTree' at option \`skein': the option type \`listOf' states its element in a carrying spelling and offers a different one" \
  "$tmpdir/nesting-planes-two-refusals-disagree.err"
check "T5 nesting-planes-two-refusals catchable  (both refusals are caught by tryEval, not an abort)" \
  "${row_nesting_planes_two_refusals/BODY/caught}" 0 "" "$tmpdir/nesting-planes-two-refusals-catch.err" 'CAUGHT'
