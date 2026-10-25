# ── A COLLECTION DECLARING NO DEFAULT IS AN OPTION DECLARING NO DEFAULT ──
# A `user` kind whose `roles` collection declares neither a `default` nor a `merge`, the kind defining
# `[ "kind" ]` and its mixin `[ "mixin" ]`, and a second kind that never defines it. The definitions
# fold as an untyped option's do, in the order they are written, the kind's and then the mixin's.
# Read where no definition of it survives, the collection is refused by name, a catchable refusal,
# where it aborted on `attribute 'default' missing`; the undefined collection still mints the kind.
{ genMerge, inputs }:
let
  kcnSchema = inputs.gen.lib.substrate.schema;
  kcnUser =
    collections: mixins: defs:
    (genMerge.evalModuleTree { } (
      [
        {
          options.schema = kcnSchema.mkSchemaOption {
            inherit collections mixins;
            baseModule = { };
          };
        }
        { config.schema.user = { }; }
      ]
      ++ map (d: { config.schema.user = d; }) defs
    )).config.schema.user;
  kcnRefused = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  kcnDefined =
    kcnUser { roles = { }; }
      [
        (kcnSchema.mkMixin { } (_: {
          roles = [ "mixin" ];
        }))
      ]
      [
        { roles = [ "kind" ]; }
      ];
  kcnUndefined = kcnUser { roles = { }; } [ ] [ ];
in
{
  kcnRead = {
    roles = kcnDefined.roles;
    undefinedRefused = kcnRefused kcnUndefined.roles;
    undefinedMinted = builtins.isString kcnUndefined.__mint.minted;
  };
}
