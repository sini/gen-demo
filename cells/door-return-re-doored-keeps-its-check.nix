# `door-return-re-doored-keeps-its-check` — a-door-return-re-entered-through-a-second-door-keeps-its-check,
# den-hoag-dyagb. A door's return for a caller's nixpkgs record is closed under its rebuilds (den-hoag-d61ws), and a
# caller may hand that return to a second door: `defineType (mkOptionType X)`, or `mkOptionType (defineType X)`. The
# second door completes the record again, and the completion derives `typeMerge` from gen's own relation, which the
# first door had not closed; or it read the caller's base off the first door's closed join, where the check already
# stood, so the check it laid on the join judged nothing. Declared twice in nixpkgs' `lib.evalModules`, each served a
# value its check rejects. Each refusal stands beside its passing twin, so a fold refusing everything cannot pass, and
# neither can one serving everything.
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
  # no `default`: the two declarations' module sets merge, and two copies of one option both stating `default` are refused (nixpkgs' `bothHave`)
  bolt = genMerge.types.submodule {
    options.warp = genMerge.mkOption { type = genMerge.types.int; };
  };
  notFive = v: !(builtins.isAttrs v) || v.warp or 0 != 5;
  short = v: !(builtins.isList v) || builtins.length v < 3;
  inherit (genMerge) mkOptionType;
  inherit (genMerge.types) defineType;
  spool = defineType (mkOptionType (ft.addCheck (ft.nullOr bolt) notFive));
  reel = defineType (mkOptionType (ft.addCheck (ft.listOf ft.int) short));
  bobbin = mkOptionType (defineType (ft.addCheck (ft.nullOr bolt) notFive));
in
{
  construct = [ "a-door-return-re-entered-through-a-second-door-keeps-its-check" ];
  check = asserts (
    refused [ spool spool ] { warp = 5; }
    && served [ spool spool ] { warp = 2; } { warp = 2; }
    && refused [ reel reel ] [ 1 2 3 ]
    && served [ reel reel ] [ 1 2 ] [ 1 2 ]
    && refused [ bobbin bobbin ] { warp = 5; }
    && served [ bobbin bobbin ] { warp = 2; } { warp = 2; }
  );
}
