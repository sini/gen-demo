# ── A NIXPKGS SUBMODULE OPTION WHOSE MODULE SET READS ITS OWN REGISTRY COMPOSES (den-hoag-gi421) ──
# The twin of `submodule-option-reading-its-own-registry-composes` with the kind option typed by
# nixpkgs' own `types.submodule`: each tassel declares one `loop-<name>` option per tassel,
# defaulting to that tassel's `braid`. The completion stamp's `refs` asks each option type whether
# it carries a ref through gen-merge's `importedCarried`, which answers a foreign submodule with its
# module set and never reads its `nestedTypes`, the module set evaluated (gen-merge's a0c4z rule),
# so the knot closes. Read through `mkInstanceRegistry` and its `attrsOf (mkInstanceType …)` sibling.
{
  genMerge,
  inputs,
  lib,
}:
let
  S = inputs.gen.lib.substrate.schema;
  M = genMerge;
  kindDecl =
    { config, ... }:
    {
      options.schema = S.mkSchemaOption { };
      config.schema.tassel = {
        options.braid = M.mkOption { type = M.types.str; };
        options.loops = M.mkOption {
          type = lib.types.submodule {
            imports = map (p: {
              options."loop-${p.name}" = lib.mkOption {
                type = lib.types.str;
                default = p.braid;
              };
            }) (builtins.attrValues config.tassels);
          };
          default = { };
        };
      };
    };
  inst.config.tassels = {
    t1.braid = "soutache";
    t2.braid = "russia";
  };
  registry = { config, ... }: { options.tassels = S.mkInstanceRegistry { } config.schema.tassel; };
  sibling =
    { config, ... }:
    {
      options.tassels = M.mkOption {
        type = M.types.attrsOf (S.mkInstanceType { } config.schema.tassel);
        default = { };
      };
    };
  read =
    construct:
    let
      ev = M.evalModuleTree { } [
        kindDecl
        construct
        inst
      ];
    in
    {
      loops = ev.config.tassels.t1.loops;
      refs = ev.config.schema.tassel.refs;
    };
in
{
  tasselLoops = {
    registry = read registry;
    sibling = read sibling;
  };
}
