# `stock-container-over-tree` — C106, den-hoag-4ifgb M0. nixpkgs' `listOf` over a gen nesting tree
# (another `evalModuleTree` call's `.type`) is re-homed as gen's own `listOf` and serves its
# elements, as nixpkgs over its own types does. It used to refuse with the tree's tombstone
# ("`moduleTree' is not an option type and does not answer `check'"): judging whether the record's
# payload and carrying spelling agree forced the tree's refusing `check`. The tree is now compared
# by its `merge` alone, and a container stating the tree while offering `str` to merge on is still
# refused, so an agreement test that accepted everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  liningTree =
    (genMerge.evalModuleTree { } [
      {
        options.weave = genMerge.mkOption {
          type = genMerge.types.str;
          default = "plain";
        };
      }
    ]).type;
  linings =
    type: def:
    (genMerge.evalModuleTree { } [
      { options.linings = genMerge.mkOption { inherit type; }; }
      { linings = def; }
    ]).config.linings;
  refuses = e: !(builtins.tryEval (builtins.deepSeq e null)).success;
in
{
  construct = [ "stock-container-over-a-gen-tree-serves" ];
  check = asserts (
    linings (lib.types.listOf liningTree) [
      { weave = "twill"; }
      { }
    ] == [
      { weave = "twill"; }
      { weave = "plain"; }
    ]
    && linings (lib.types.listOf liningTree) [ ] == [ ]
    # control: the payload offers `str` and the carrying spelling states the tree, over a definition
    # the tree alone would serve
    && refuses (
      linings (lib.types.listOf lib.types.str // { nestedTypes.elemType = liningTree; }) [
        { weave = "twill"; }
      ]
    )
  );
}
