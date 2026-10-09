# ── A REFINED SUBMODULE OPTION WHOSE MODULE SET READS ITS OWN REGISTRY COMPOSES (den-hoag-60hql) ──
# The dqw5z knot (`passantLoops`) with the submodule under gen-schema's `refined`: each ruche declares
# one `pleat-<name>` option per ruche, defaulting to that ruche's `gather`. `refined` builds its record
# as a `//` copy of the submodule's and re-enters gen-merge's `mkOptionType`; the copy keeps
# `carries.moduleSet`, and the door leaves a record carrying a module set in gen's spelling with its
# self-evaluating `nestedTypes` unread (gen-merge `evaluatesOwnRoles`). Read through an `attrsOf (refined …)` option
# with a defined element, and through the kind's `refs`, which asks the bare `refined` field's type
# whether it carries a ref.
{ genMerge, inputs }:
let
  S = inputs.gen.lib.substrate.schema;
  M = genMerge;
  always = {
    check = _: true;
    message = "never fails";
  };
  pleatsOf = ruches: {
    imports = map (r: {
      options."pleat-${r.name}" = M.mkOption {
        type = M.types.str;
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
          type = M.types.attrsOf (S.refined (M.types.submodule (pleatsOf config.ruches)) [ always ]);
          default = { };
        };
        options.smock = M.mkOption {
          type = S.refined (M.types.submodule (pleatsOf config.ruches)) [ (always // { lazy = true; }) ];
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
  rucheRefinedPleats = {
    pleats = ev.config.ruches.r1.pleats;
    smock = ev.config.ruches.r1.smock;
    refs = ev.config.schema.ruche.refs;
  };
}
