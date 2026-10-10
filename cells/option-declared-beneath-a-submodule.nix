# `option-declared-beneath-a-submodule` — den-hoag-3pnlv. One module declares `nix.settings` as a
# freeform `submodule` with one typed option; another declares `nix.settings.sandbox` beneath it, the
# NixOS shape. nixpkgs reads the second declaration as one more module of the submodule
# (`optionTreeToOption`), so the option set is both; gen-merge's engine reads the same set, in both
# declaration orders, under gen's `submodule` and nixpkgs'. The live arm is `lib.evalModules`, and a
# beneath declaration under an `int` stays refused by both, as nixpkgs refuses it. Before, gen-merge
# refused every row as a "leaf/group collision".
{
  asserts,
  genMerge,
  lib,
}:
let
  shape = mk: t: sub: [
    {
      options.nix.settings = mk {
        type = sub {
          freeformType = t.attrsOf t.str;
          options.max-jobs = mk {
            type = t.int;
            default = 1;
          };
        };
        default = { };
      };
    }
    {
      options.nix.settings.sandbox = mk {
        type = t.bool;
        default = true;
      };
    }
    {
      nix.settings = {
        max-jobs = 4;
        extra-x = "y";
      };
    }
  ];
  read =
    eval: ms:
    let
      r = builtins.tryEval (
        let
          v = (eval ms).config.nix.settings;
        in
        builtins.deepSeq v v
      );
    in
    if r.success then r.value else null;
  gen = read (genMerge.evalModuleTree { });
  ref = read (ms: lib.evalModules { modules = ms; });
  rows = {
    gen = shape genMerge.mkOption genMerge.types genMerge.types.submodule;
    np = shape lib.mkOption lib.types lib.types.submodule;
  };
  orders = ms: [
    ms
    (lib.reverseList ms)
  ];
  underInt = mk: t: [
    {
      options.nix.settings = mk {
        type = t.int;
        default = 1;
      };
    }
    {
      options.nix.settings.sandbox = mk {
        type = t.bool;
        default = true;
      };
    }
  ];
in
{
  construct = [ "an-option-declared-beneath-a-submodule-joins-its-module-set" ];
  check = asserts (
    lib.all (
      ms:
      lib.all (o: ref o != null && gen o == ref o) (orders ms)
      &&
        ref ms == {
          extra-x = "y";
          max-jobs = 4;
          sandbox = true;
        }
    ) (builtins.attrValues rows)
    && gen (underInt genMerge.mkOption genMerge.types) == null
    && ref (underInt lib.mkOption lib.types) == null
  );
}
