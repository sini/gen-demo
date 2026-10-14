# `derived-container-verify-copy-evaluates-its-definition` — a-derived-container-verify-copy-evaluates-its-definition,
# den-hoag-mym0d. `deriveType` over a `verify` copy of a nixpkgs container of a gen submodule served the definition
# unevaluated: the import re-homed the stock container and handed the overlay back unhomed, so the derivation folded
# as a leaf, `{ warp = 2; }` came back without the submodule's `weft` default, and a `verify` admitting everything
# over an `addCheck` beneath served `{ warp = 5; }`, which the check rejects. The overlay now rides on the re-home.
# Read in nixpkgs' `lib.evalModules` and in gen-merge's `evalModuleTree`, through `nullOr`, `attrsOf` and `either`:
# each admitted definition is served evaluated, and each rejected one is refused.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  gt = genMerge.types;
  bolt = gt.submodule {
    options.warp = genMerge.mkOption {
      type = gt.int;
      default = 0;
    };
    options.weft = genMerge.mkOption {
      type = gt.int;
      default = 0;
    };
  };
  notFive =
    v: !(builtins.isAttrs v) || (v.warp or 0 != 5 && builtins.all notFive (builtins.attrValues v));
  derived = t: genMerge.deriveType { } "loom" t;
  read =
    eval: mkOption: type: v:
    (eval {
      modules = [
        { options.bobbin = mkOption { inherit type; }; }
        { bobbin = v; }
      ];
    }).config.bobbin;
  engines = [
    (read lib.evalModules lib.mkOption)
    (read (r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules) genMerge.mkOption)
  ];
  attempt =
    run: type: v:
    builtins.tryEval (builtins.deepSeq (run type v) (run type v));
  served =
    type: v: want:
    builtins.all (
      run:
      attempt run type v == {
        success = true;
        value = want;
      }
    ) engines;
  refused = type: v: builtins.all (run: !(attempt run type v).success) engines;
  spool = derived (ft.nullOr bolt // { verify = v: if notFive v then null else "five"; });
  rack = derived (ft.attrsOf bolt // { verify = v: if notFive v then null else "five"; });
  hank = derived (ft.addCheck (ft.either bolt ft.str) notFive // { verify = _: null; });
in
{
  construct = [ "a-derived-container-verify-copy-evaluates-its-definition" ];
  check = asserts (
    served spool { warp = 2; } {
      warp = 2;
      weft = 0;
    }
    && refused spool { warp = 5; }
    && served rack { k.warp = 2; } {
      k = {
        warp = 2;
        weft = 0;
      };
    }
    && refused rack { k.warp = 5; }
    && served hank { warp = 2; } {
      warp = 2;
      weft = 0;
    }
    && refused hank { warp = 5; }
  );
}
