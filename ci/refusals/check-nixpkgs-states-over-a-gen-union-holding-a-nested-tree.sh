# shellcheck shell=bash
# ── row 126 -- a check nixpkgs states over a gen union holding a nested tree, BY NAME (C110,
#    den-hoag-4ifgb M-A.3) ──
# A check `addCheck` states over gen-merge's `either tree str` is carried and evaluated: the tree's
# `check` is its module-value domain (den-hoag-f8mgj arm Q), so the union's check reads only the
# value. A failing check (`isAttrs` on a string) is refused by name, which a fold that dropped the
# check would serve; a passing one (`isString`) serves the value, which a fold that refused every
# such check would not. The unplanted arm is the same union without `addCheck` and serves the value,
# so a fold refusing every such union cannot pass.
row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_tree='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  selvage = (genMerge.evalModuleTree { } [ { options.weave = genMerge.mkOption { type = genMerge.types.str; default = "plain"; }; } ]).type;
in (genMerge.evalModuleTree { } [
    { options.spool = genMerge.mkOption { type = TYPE; }; }
    { spool = "sateen"; }
  ]).config.spool'
row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treestated='genMerge.types.either selvage genMerge.types.str'
row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treeplant="lib.types.addCheck ($row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treestated) builtins.isAttrs"
row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treepassing="lib.types.addCheck ($row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treestated) builtins.isString"
row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treeunplanted="${row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_tree/TYPE/$row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treestated}"
row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treeplanted="${row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_tree/TYPE/$row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treeplant}"
row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treeserved="${row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_tree/TYPE/$row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treepassing}"
check "T5 check-nixpkgs-states-over-a-gen-union-holding-a-nested-tree unplanted (the gen union holding a tree, no added check)" "$row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treeunplanted" 0 "" \
  "$tmpdir/check-nixpkgs-states-over-a-gen-union-holding-a-nested-tree-green.err" 'sateen'
check "T5 check-nixpkgs-states-over-a-gen-union-holding-a-nested-tree passing   (a passing check added over a gen union holding a tree)" "$row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treeserved" 0 "" \
  "$tmpdir/check-nixpkgs-states-over-a-gen-union-holding-a-nested-tree-passing.err" 'sateen'
check "T5 check-nixpkgs-states-over-a-gen-union-holding-a-nested-tree planted   (a failing check added over a gen union holding a tree)" "$row_check_nixpkgs_states_over_a_gen_union_holding_a_nested_treeplanted" 1 \
  "gen-merge: a definition for option \`spool' is not of type \`(submodule) or string'" \
  "$tmpdir/check-nixpkgs-states-over-a-gen-union-holding-a-nested-tree-red.err"
