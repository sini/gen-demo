# `attr-list-entries` — attr-list-entries-over-a-gen-element-each-read-their-own-tree,
# den-hoag-lif3n (ADR-0039, the serve half). nixpkgs' `attrListOf` folds every definition's entry
# at one loc. Over a gen submodule, a gen union over it and a gen tree container over it, each entry
# is keyed at its own position of the one evaluation and reads its own tree, in nixpkgs' order,
# where every entry read the last one's. Red if the entries are keyed by their loc alone.

{
  asserts,
  genMerge,
  lib,
}:

let
  t = genMerge.types;
  tagged = t.submodule {
    options.tags = genMerge.mkOption {
      type = t.listOf t.str;
      default = [ ];
    };
  };
  tagsOf =
    type: wrap: read:
    let
      d = tag: { o = wrap { tags = [ tag ]; }; };
    in
    builtins.concatMap (x: (read x.o).tags)
      (genMerge.evalModuleTree { } [
        { options.xs = genMerge.mkOption { type = lib.types.attrListOf type; }; }
        {
          key = "mA";
          _file = "zz";
          config.xs = d "p";
        }
        {
          key = "mB";
          _file = "aa";
          config.xs = d "q";
        }
        {
          key = "mC";
          _file = "zz";
          config.xs = genMerge.mkMerge [
            (d "r")
            (d "s")
          ];
        }
      ]).config.xs;
  order = [
    "r"
    "s"
    "q"
    "p"
  ];
in
{
  construct = [ "attr-list-entries-over-a-gen-element-each-read-their-own-tree" ];
  check = asserts (
    tagsOf tagged (x: x) (x: x) == order
    && tagsOf (t.either tagged t.str) (x: x) (x: x) == order
    && tagsOf (t.attrsOf tagged) (x: { k = x; }) (x: x.k) == order
  );
}
