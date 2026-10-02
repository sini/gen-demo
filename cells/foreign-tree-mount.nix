# `foreign-tree-mount` — C128, den-hoag-foreign-mount-parity-knhyg. nixpkgs' own `lib.evalModules`
# mounts a BARE gen module tree (`spool`, another `evalModuleTree` call's `.type`) as an option type,
# and under a nixpkgs `attrsOf`, and renders the docs of both. Each value and each doc entry is
# nixpkgs' for the same construction over its own `(lib.evalModules …).type`. gen-merge used to
# refuse the mount by name at the first protocol read (`getSubModules`). The control is a definition
# outside the tree's module domain, which is refused, catchably, as nixpkgs refuses it.
{
  asserts,
  genMerge,
  lib,
}:
let
  mods = mk: [
    {
      options.spool = mk {
        type = lib.types.str;
        default = "none";
        description = "spool";
      };
    }
  ];
  spool = (genMerge.evalModuleTree { modules = mods genMerge.mkOption; }).type;
  ref = (lib.evalModules { modules = mods lib.mkOption; }).type;
  eval =
    type: v:
    lib.evalModules {
      modules = [
        {
          options.seam = lib.mkOption {
            inherit type;
            description = "seam";
          };
        }
        { seam = v; }
      ];
    };
  shown =
    type:
    map
      (o: {
        inherit (o)
          loc
          name
          type
          declarations
          ;
      })
      (
        builtins.filter (o: o.visible && !o.internal) (lib.optionAttrSetToDocList (eval type { }).options)
      );
  refuses = e: !(builtins.tryEval (builtins.deepSeq e null)).success;
in
{
  construct = [ "C128" ];
  check = asserts (
    (eval spool { spool = "sateen"; }).config.seam.spool == "sateen"
    && (eval spool { }).config.seam.spool == "none"
    && (eval (lib.types.attrsOf spool) { warp.spool = "sateen"; }).config.seam.warp.spool == "sateen"
    && shown spool == shown ref
    && shown (lib.types.attrsOf spool) == shown (lib.types.attrsOf ref)
    # control: a definition outside the module domain is refused, catchably, here and by nixpkgs
    && refuses (eval spool "selvedge").config.seam
    && refuses (eval ref "selvedge").config.seam
  );
}
