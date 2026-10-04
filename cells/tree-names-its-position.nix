# `tree-names-its-position` — C138, den-hoag-tree-type-no-name-arg-xy2r0. A gen module tree (`spool`,
# an `evalModuleTree` call's `.type`) whose module reads `name` is named as nixpkgs' `submoduleWith`
# names it: the attribute name under `attrsOf`, mounted in nixpkgs' own `lib.evalModules` and in
# gen-merge's `evalModuleTree`, and `‹name›` in its docs. The name is an overridable
# `_module.args.name` definition, so a module's `mkForce` wins. Each must equal the same construction
# over nixpkgs' `(lib.evalModules …).type`, where gen-merge refused the tree's module by name
# (`` module argument `name' is not defined ``).
{
  asserts,
  genMerge,
  lib,
}:
let
  mods = mk: [
    (
      { name, ... }:
      {
        options.weft = mk {
          type = lib.types.str;
          default = name;
        };
      }
    )
  ];
  forced = mkForce: [ { _module.args.name = mkForce "forced"; } ];
  spool = extra: (genMerge.evalModuleTree { } (mods genMerge.mkOption ++ extra)).type;
  ref = extra: (lib.evalModules { modules = mods lib.mkOption ++ extra; }).type;
  # `eval` and `mkOption` are the evaluating module system's; `P` the container's.
  warp =
    eval: mkOption: P: type:
    (eval {
      modules = [
        { options.seam = mkOption { type = P.attrsOf type; }; }
        { seam.warp = { }; }
      ];
    }).config.seam.warp.weft;
  mounted = warp lib.evalModules lib.mkOption lib.types;
  native = warp (
    r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
  ) genMerge.mkOption genMerge.types;
  docs = type: (type.getSubOptions [ ]).weft.default;
in
{
  construct = [ "C138" ];
  check = asserts (
    mounted (ref [ ]) == "warp"
    && mounted (spool [ ]) == mounted (ref [ ])
    && native (spool [ ]) == mounted (ref [ ])
    && docs (ref [ ]) == "‹name›"
    && docs (spool [ ]) == docs (ref [ ])
    && mounted (ref (forced lib.mkForce)) == "forced"
    && mounted (spool (forced genMerge.mkForce)) == mounted (ref (forced lib.mkForce))
  );
}
