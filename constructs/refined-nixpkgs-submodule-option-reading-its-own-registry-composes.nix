# ── A REFINED NIXPKGS SUBMODULE OPTION WHOSE MODULE SET READS ITS OWN REGISTRY COMPOSES (den-hoag-60hql) ──
# The twin of `refined-submodule-option-reading-its-own-registry-composes` with the submodule spelled
# by nixpkgs (`lib.types.submodule`, `lib.mkOption`) and handed to gen-schema's `refined` raw: each
# ruche declares one `pleat-<name>` option per ruche, defaulting to that ruche's `gather`. `refined`
# imports a foreign base through gen-merge's `mkOptionType` before taking its `//` copy, so the copy
# keeps the import's `carries.moduleSet` and the door leaves its self-evaluating `nestedTypes` unread
# (gen-merge `evaluatesOwnRoles`). Read through an `attrsOf (refined …)` option with a defined
# element, a lazily refined field, and the kind's `refs`.
{
  genMerge,
  inputs,
  lib,
}:
let
  S = inputs.gen.lib.substrate.schema;
  M = genMerge;
  always = {
    check = _: true;
    message = "never fails";
  };
  pleatsOf = ruches: {
    imports = map (r: {
      options."pleat-${r.name}" = lib.mkOption {
        type = lib.types.str;
        default = r.gather;
      };
    }) (builtins.attrValues ruches);
  };
  kindDecl =
    { config, ... }:
    {
      options.schema = S.mkSchemaOption { };
      config.schema.ruche = {
        options.gather = M.mkOption { type = M.types.str; };
        options.pleats = M.mkOption {
          type = M.types.attrsOf (S.refined (lib.types.submodule (pleatsOf config.ruches)) [ always ]);
          default = { };
        };
        options.smock = M.mkOption {
          type = S.refined (lib.types.submodule (pleatsOf config.ruches)) [ (always // { lazy = true; }) ];
          default = { };
        };
      };
    };
  inst.config.ruches = {
    r1.gather = "shirring";
    r2.gather = "gauging";
    r1.pleats.box = { };
  };
  registry = { config, ... }: { options.ruches = S.mkInstanceRegistry { } config.schema.ruche; };
  ev = M.evalModuleTree { } [
    kindDecl
    registry
    inst
  ];
in
{
  rucheNixpkgsRefinedPleats = {
    pleats = ev.config.ruches.r1.pleats;
    smock = ev.config.ruches.r1.smock;
    refs = ev.config.schema.ruche.refs;
  };
}
