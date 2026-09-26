# `freeform-leaf-type-folds` — C76, den-hoag-hgi8v. A LEAF type used as a tree's `freeformType`
# folds the undeclared definitions by that leaf's own fold, as nixpkgs' `lib.evalModules` folds them
# (`freeformType.merge prefix defs`): one file defining `selvage` reads `"twill"` under `types.str`
# and under a bare `defineType` leaf, where gen-merge used to abort uncatchably at the freeform fold.
# Beside it, two files defining different undeclared keys under the same leaf are refused
# catchably, as nixpkgs refuses them, so a fold that accepts everything cannot pass; and the same
# two files under `attrsOf str` read both keys, so a fold that refuses every pair cannot either.
{ asserts, genMerge }:
let
  T = genMerge.types;
  read =
    freeformType: defs:
    (genMerge.evalModuleTree {
      modules = [ { inherit freeformType; } ] ++ defs;
    }).config;
  warp = {
    _file = "/demo/warp.nix";
    selvage = "twill";
  };
  weft = {
    _file = "/demo/weft.nix";
    bobbin = "sateen";
  };
  attempt = v: builtins.tryEval (builtins.deepSeq v v);
  refused = v: !(attempt v).success;
  byStr = attempt (read T.str [ warp ]).selvage;
  byLeaf = attempt (read (T.defineType { name = "shuttle"; }) [ warp ]).selvage;
  byAttrs = attempt (
    read (T.attrsOf T.str) [
      warp
      weft
    ]
  );
in
{
  construct = [ "C76" ];
  check = asserts (
    byStr.success
    && byStr.value == "twill"
    && byLeaf.success
    && byLeaf.value == "twill"
    && refused (
      read T.str [
        warp
        weft
      ]
    )
    && byAttrs.success
    &&
      byAttrs.value == {
        selvage = "twill";
        bobbin = "sateen";
      }
  );
}
