# `caller-check-residue-re-doored` — a-caller-check-on-a-verify-copy-survives-the-door and
# a-redeclared-container-of-a-foreign-submodule-keeps-a-caller-check, den-hoag-jyisy. A caller may lay a check on a
# `// { verify }` copy of a gen record before a published door completes it. The doors answer such a copy in their
# `verify` arm, ahead of the arm that closes a caller's check (den-hoag-1b55t): a copy the door re-completes was completed
# from gen data closed over the earlier checks only, so its join (declared twice) dropped the laid check; a copy the door
# returns as itself kept its completion's module-set rebuild, so nixpkgs' fixup dropped it even declared once. And a
# check carried onto a redeclared module-set join was stated on the join's `check` but not on its `merge.v2` headError,
# which is all nixpkgs' `lib.evalModules` reads, so `defineType` over a checked gen `nullOr` of a keyed nixpkgs
# submodule, declared twice, served what the check rejects. The closure that keeps a laid check replaces the copy's
# module-set rebuild, which carried a `verify` laid after a check, so it carries that `verify` again: a module-function
# definition, which no check reads, is judged by the `verify` on the merged value. Each refusal stands beside its passing
# twin, so a fold refusing everything cannot pass, and neither can one serving everything.
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
  # a nixpkgs submodule with a `key`, so a redeclaration names one module and evaluates
  skein = ft.submodule {
    key = "skein";
    options.warp = lib.mkOption {
      type = ft.int;
      default = 0;
    };
  };
  below10 = v: !(builtins.isInt v) || v < 10;
  notFive = v: v != 5;
  notThreeWarp = v: !(builtins.isAttrs v) || v.warp or 0 != 3;
  notTwoWarp = v: !(builtins.isAttrs v) || v.warp or 0 != 2;
  vacuous = _: null;
  inherit (genMerge) mkOptionType;
  inherit (genMerge.types) defineType nullOr;
  # a verify copy the door re-completes, declared twice
  latch = defineType (
    ft.addCheck (mkOptionType (ft.addCheck ft.int below10) // { verify = vacuous; }) notFive
  );
  pawl = mkOptionType (
    ft.addCheck (mkOptionType (ft.addCheck ft.int below10) // { verify = vacuous; }) notFive
  );
  # a verify copy the door returns as itself, declared once
  copied = nullOr bolt // {
    verify = vacuous;
  };
  heddle = defineType (copied // { check = v: copied.check v && notThreeWarp v; });
  # a `verify` laid after a check, judging a module-function definition on the merged value
  shuttle = mkOptionType (
    ft.addCheck (nullOr bolt) notTwoWarp
    // {
      verify = v: if notTwoWarp v then null else "rejected by notTwoWarp";
    }
  );
  # a checked gen container of a keyed nixpkgs submodule, declared twice and after its unchecked self
  reed = defineType (ft.addCheck (nullOr skein) notTwoWarp);
in
{
  construct = [
    "a-caller-check-on-a-verify-copy-survives-the-door"
    "a-redeclared-container-of-a-foreign-submodule-keeps-a-caller-check"
  ];
  check = asserts (
    refused [ latch latch ] 5
    && served [ latch latch ] 3 3
    && refused [ latch latch ] 20
    && refused [ pawl pawl ] 5
    && served [ pawl pawl ] 3 3
    && refused [ heddle ] { warp = 3; }
    && served [ heddle ] { warp = 1; } { warp = 1; }
    && refused [ shuttle ] ({ ... }: { warp = 2; })
    && served [ shuttle ] ({ ... }: { warp = 1; }) { warp = 1; }
    && refused [ reed reed ] { warp = 2; }
    && served [ reed reed ] { warp = 1; } { warp = 1; }
    && refused [ (nullOr skein) reed ] { warp = 2; }
    && served [ (nullOr skein) reed ] { warp = 1; } { warp = 1; }
  );
}
