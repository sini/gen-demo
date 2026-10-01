# `foreign-union-mount` — C123, den-hoag-f8mgj arm Q. nixpkgs' own `lib.evalModules` mounts gen's
# `either spool str`, where `spool` is a nested module tree (another `evalModuleTree` call's
# `.type`). The tree's `check` answers its module-value domain, so the foreign eval folds the tree
# and reads `sateen` through it and `selvedge` as the string, which are nixpkgs' values for the same
# construction over its own `(evalModules …).type`. gen-merge used to refuse both with the tree's
# tombstone `check`. The control is the bare `spool` mounted there, which is still refused,
# catchably, so a mount that served everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  spool =
    (genMerge.evalModuleTree {
      modules = [
        {
          options.spool = genMerge.mkOption {
            type = genMerge.types.str;
            default = "none";
          };
        }
      ];
    }).type;
  mount =
    type: v:
    (lib.evalModules {
      modules = [
        { options.seam = lib.mkOption { inherit type; }; }
        { seam = v; }
      ];
    }).config.seam;
  union = genMerge.types.either spool genMerge.types.str;
  refuses = e: !(builtins.tryEval (builtins.deepSeq e null)).success;
in
{
  construct = [ "C123" ];
  check = asserts (
    (mount union { spool = "sateen"; }).spool == "sateen"
    && mount union "selvedge" == "selvedge"
    # control: the bare tree, mounted where nothing holds it, is not an option type
    && refuses (mount spool { spool = "sateen"; })
  );
}
