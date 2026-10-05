# `mkoptiontype-key-reads-a-sibling` — C196, den-hoag-11c5o. A check-only `mkOptionType` decides a
# shared attrset key where that key is read, so one key's definitions may read a sibling of the same
# option: `heddle.a = config.heddle.b` in two files and `heddle.b = 1` in a third reads
# `{ a = 1; b = 1; }`, as nixpkgs' `lib.evalModules` reads it, where deciding every key before
# returning the set recursed uncatchably on Nix, Determinate and Lix. Beside it, a disagreement at `a`
# leaves `b` readable and refuses a read of `a` catchably, so a fold that accepts every shared key
# cannot pass.
{ asserts, genMerge }:
let
  thread = genMerge.mkOptionType {
    name = "thread";
    check = builtins.isAttrs;
  };
  read =
    modules:
    (genMerge.evalModuleTree { } (
      [ { options.heddle = genMerge.mkOption { type = thread; }; } ] ++ modules
    )).config.heddle;
  served = read [
    (
      { config, ... }:
      {
        _file = "/demo/warp.nix";
        heddle.a = config.heddle.b;
      }
    )
    (
      { config, ... }:
      {
        _file = "/demo/weft.nix";
        heddle.a = config.heddle.b;
      }
    )
    {
      _file = "/demo/selvage.nix";
      heddle.b = 1;
    }
  ];
  disagreeing = read [
    {
      _file = "/demo/warp.nix";
      heddle = {
        a = 1;
        b = 0;
      };
    }
    {
      _file = "/demo/weft.nix";
      heddle.a = 2;
    }
  ];
in
{
  construct = [ "C196" ];
  check = asserts (
    served == {
      a = 1;
      b = 1;
    }
    && disagreeing.b == 0
    && !(builtins.tryEval disagreeing.a).success
  );
}
