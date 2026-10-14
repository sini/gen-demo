# `caller-check-on-a-door-return-re-doored` — a-caller-check-laid-on-a-door-return-survives-a-second-door,
# den-hoag-1b55t. A door's return is closed under its rebuilds over the check its caller handed it (den-hoag-d61ws), and
# a second door re-completes it from gen data those rebuilds closed (den-hoag-dyagb). A caller may lay a further check
# on the return with nixpkgs' `addCheck` before handing it on: `mkOptionType (addCheck (mkOptionType X) q)`. The
# return's rebuilds, and the gen data the second door completes from, ride into the `addCheck` copy closed over the
# first check only, so the second door's `typeMerge` (declared twice) and its `substSubModules` (a module set,
# declared once) dropped `q`, and nixpkgs' `lib.evalModules` served a value `q` rejects. Each refusal stands beside its
# passing twin, so a fold refusing everything cannot pass, and neither can one serving everything.
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
  below10 = v: !(builtins.isInt v) || v < 10;
  notFive = v: v != 5;
  notTwo = v: !(builtins.isAttrs v) || v.warp or 0 != 2;
  notFiveWarp = v: !(builtins.isAttrs v) || v.warp or 0 != 5;
  inherit (genMerge) mkOptionType deriveType;
  inherit (genMerge.types) defineType;
  ring = mkOptionType (ft.addCheck (mkOptionType (ft.addCheck ft.int below10)) notFive);
  laid = ft.addCheck (mkOptionType (ft.addCheck (ft.nullOr bolt) notTwo)) notFiveWarp;
  spool = defineType laid;
  spindle = deriveType { } "spindle" laid;
in
{
  construct = [ "a-caller-check-laid-on-a-door-return-survives-a-second-door" ];
  check = asserts (
    refused [ ring ring ] 5
    && served [ ring ring ] 3 3
    && refused [ ring ring ] 20
    && refused [ spool ] { warp = 5; }
    && served [ spool ] { warp = 1; } { warp = 1; }
    && refused [ spool ] { warp = 2; }
    && refused [ spindle ] { warp = 5; }
    && served [ spindle ] { warp = 1; } { warp = 1; }
  );
}
