# `door-return-closed-under-its-rebuilds` — a-doors-return-keeps-its-check-through-every-rebuild, den-hoag-d61ws.
# `mkOptionType` over nixpkgs `addCheck` of a nixpkgs `nullOr` holding a gen `submodule`, or of a nixpkgs `listOf`,
# returns gen's own record carrying the check. nixpkgs' `lib.evalModules` re-derives a declared type through the
# record's rebuilds: `substSubModules` when it mounts the option, and the later declaration's `typeMerge` when the option
# is declared twice. Those rebuilds were the constructor's and dropped the check, so gen-merge served a rejected value
# where `defineType` refused it. The door's return now answers its rebuilds closed: the `nullOr` declared once, the
# `listOf` declared after its plain twin and twice. Each refusal stands beside its passing twin, so a fold refusing
# everything cannot pass, and neither can one serving everything.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  read =
    types: v:
    (lib.evalModules {
      modules = map (type: { options.bobbin = lib.mkOption { inherit type; }; }) types ++ [
        { bobbin = v; }
      ];
    }).config.bobbin;
  attempt = types: v: builtins.tryEval (builtins.deepSeq (read types v) (read types v));
  refused = types: v: !(attempt types v).success;
  served =
    types: v: want:
    (attempt types v) == {
      success = true;
      value = want;
    };
  bolt = genMerge.types.submodule {
    options.warp = genMerge.mkOption {
      type = genMerge.types.int;
      default = 0;
    };
  };
  notFive = v: !(builtins.isAttrs v) || v.warp or 0 != 5;
  short = v: !(builtins.isList v) || builtins.length v < 3;
  spool = genMerge.mkOptionType (ft.addCheck (ft.nullOr bolt) notFive);
  reel = genMerge.mkOptionType (ft.addCheck (ft.listOf ft.int) short);
in
{
  construct = [ "a-doors-return-keeps-its-check-through-every-rebuild" ];
  check = asserts (
    refused [ spool ] { warp = 5; }
    && served [ spool ] { warp = 2; } { warp = 2; }
    && served [ spool ] null null
    && refused [ (ft.listOf ft.int) reel ] [ 1 2 3 ]
    && served [ (ft.listOf ft.int) reel ] [ 1 2 ] [ 1 2 ]
    && refused [ reel reel ] [ 1 2 3 ]
    && served [ reel reel ] [ 1 2 ] [ 1 2 ]
  );
}
