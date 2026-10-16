# `verify-copy-over-a-leaf-container-chain` — den-hoag-c922w. A gen `attrsOf (listOf (nullOr int))` copied with a
# `verify` is used raw as an option's type. Its `verify` judges the merged value: a split is served whole, and a value
# holding a 1 is refused by name. Each element still takes the fold's three passes where a definition carries a
# property, at every level of the chain: an element's `mkIf false` is dropped, an element's `mkForce` is discharged,
# and a key's `mkMerge`, `mkForce` and `mkAfter` are resolved. A definition list with no property is folded without
# the passes, which map it to itself.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  read =
    type: v:
    (genMerge.evalModuleTree { } (
      [ { options.spool = genMerge.mkOption { inherit type; }; } ] ++ map (d: { spool = d; }) v
    )).config.spool;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
  served =
    ty: v: want:
    let
      r = builtins.tryEval (builtins.deepSeq (read ty v) (read ty v));
    in
    r.success && r.value == want;
  noOne = v: if lib.any (l: lib.elem 1 l) (builtins.attrValues v) then "holds a 1" else null;
  chain = t.attrsOf (t.listOf (t.nullOr t.int)) // {
    verify = noOne;
  };
in
{
  construct = [ "a-verify-copy-of-a-leaf-container-chain-judges-its-merged-value" ];
  check = asserts (
    served chain
      [
        {
          k = [
            2
            null
          ];
        }
        {
          k = [ 3 ];
          j = [ ];
        }
      ]
      {
        j = [ ];
        k = [
          3
          2
          null
        ];
      }
    && refused (
      read chain [
        { k = [ 2 ]; }
        { j = [ 1 ]; }
      ]
    )
    && served chain [
      {
        k = [
          (lib.mkIf false 1)
          2
        ];
      }
    ] { k = [ 2 ]; }
    && served chain [ { k = [ (lib.mkForce 3) ]; } ] { k = [ 3 ]; }
    &&
      served chain
        [
          {
            k = lib.mkMerge [
              [ 2 ]
              [ 3 ]
            ];
          }
        ]
        {
          k = [
            2
            3
          ];
        }
    && served chain [
      { k = lib.mkForce [ 4 ]; }
      { k = [ 5 ]; }
    ] { k = [ 4 ]; }
    &&
      served chain
        [
          { k = lib.mkAfter [ 6 ]; }
          { k = [ 7 ]; }
        ]
        {
          k = [
            7
            6
          ];
        }
  );
}
