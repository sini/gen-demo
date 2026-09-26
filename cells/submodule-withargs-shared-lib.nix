# `submodule-withargs-shared-lib` — C77, den-hoag-5xio7. One nixpkgs `lib`, handed to a submodule
# through `withArgs` by two declarations of one option, merges on Nix, Determinate and Lix alike,
# where Nix and Determinate threw on a removed nixpkgs alias the comparison forced. The `lib` is the
# flake's own, reaching each declaring module as a `specialArgs` formal, and a module inside the
# submodule reads it back. Beside it, two declarations handing DIFFERENT values for `lib` are still
# refused catchably on all three, so a relation that calls every shared key equal cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  reads =
    { lib, ... }:
    {
      options.seen = genMerge.mkOption {
        type = t.str;
        default = if lib ? version then "LIB-ARRIVED" else "NOT-A-LIB";
      };
    };
  declare =
    file: argsOf:
    { lib, ... }:
    {
      _file = file;
      options.loom = genMerge.mkOption { type = (t.submodule [ reads ]).withArgs (argsOf lib); };
    };
  loom =
    a: b:
    builtins.tryEval
      (genMerge.evalModuleTree {
        specialArgs = { inherit lib; };
        modules = [
          (declare "/demo/warp.nix" a)
          (declare "/demo/weft.nix" b)
          { loom = { }; }
        ];
      }).config.loom.seen;
in
{
  construct = [ "C77" ];
  check = asserts (
    loom (l: { lib = l; }) (l: {
      lib = l;
    }) == {
      success = true;
      value = "LIB-ARRIVED";
    }
    && !(loom (l: { lib = l; }) (_: {
      lib = builtins;
    })).success
  );
}
