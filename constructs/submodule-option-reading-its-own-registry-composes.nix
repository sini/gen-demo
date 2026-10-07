# ── A SUBMODULE OPTION WHOSE MODULE SET READS ITS OWN REGISTRY COMPOSES (den-hoag-dqw5z) ──
# A kind's option is typed by a submodule whose imports are a function of every instance's value in
# the registry being built: each passant declares one `loop-<name>` option per passant, defaulting to
# that passant's `braid`. The instance's completion stamp compares the kind's `refs` at the first
# import, and `refs` asks each option type whether it carries a ref; gen-schema reads that off the
# type's `carries`, never off the submodule's `nestedTypes`, which is its own module set evaluated
# (gen-merge's a0c4z rule), so the knot closes. Read through `mkInstanceRegistry` and through its
# `attrsOf (mkInstanceType …)` sibling.
{ genMerge, inputs }:
let
  S = inputs.gen.lib.substrate.schema;
  M = genMerge;
  kindDecl =
    { config, ... }:
    {
      options.schema = S.mkSchemaOption { };
      config.schema.passant = {
        options.braid = M.mkOption { type = M.types.str; };
        options.loops = M.mkOption {
          type = M.types.submodule {
            imports = map (p: {
              options."loop-${p.name}" = M.mkOption {
                type = M.types.str;
                default = p.braid;
              };
            }) (builtins.attrValues config.passants);
          };
          default = { };
        };
      };
    };
  inst.config.passants = {
    p1.braid = "soutache";
    p2.braid = "russia";
  };
  registry = { config, ... }: { options.passants = S.mkInstanceRegistry { } config.schema.passant; };
  sibling =
    { config, ... }:
    {
      options.passants = M.mkOption {
        type = M.types.attrsOf (S.mkInstanceType { } config.schema.passant);
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
      loops = ev.config.passants.p1.loops;
      refs = ev.config.schema.passant.refs;
    };
in
{
  passantLoops = {
    registry = read registry;
    sibling = read sibling;
  };
}
