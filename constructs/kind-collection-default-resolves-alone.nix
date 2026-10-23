# ── A COLLECTION'S DEFAULT IS ONE DEFINITION OF THE COLLECTION, RESOLVED ALONE ──
# A `user` kind whose `classes` default carries `mkIf true` and `mkDefault` on its elements and whose
# `metadata` default carries `mkIf true` on a key, the kind defining one more class and its mixin
# one more. The default is resolved alone, as an option's default is, and is the fold's seed, so
# each element and key resolves and the definitions follow it. A default with a property at its
# top (`mkIf true [ "x" ]`) is refused by name, a catchable refusal, where its raw record was served.
{ genMerge, inputs }:
let
  kcdSchema = inputs.gen.lib.substrate.schema;
  kcdUser =
    collections: mixins: defs:
    (genMerge.evalModuleTree { } (
      [
        {
          options.schema = kcdSchema.mkSchemaOption {
            inherit collections mixins;
            baseModule = { };
          };
        }
        { config.schema.user = { }; }
      ]
      ++ map (d: { config.schema.user = d; }) defs
    )).config.schema.user;
  kcdKind =
    kcdUser
      {
        classes.default = [
          (genMerge.mkIf true "nixos")
          (genMerge.mkDefault "darwin")
        ];
        metadata.default.region = genMerge.mkIf true "eu";
      }
      [
        (kcdSchema.mkMixin { } (_: {
          classes = [ "mixin" ];
        }))
      ]
      [ { classes = [ "kind" ]; } ];
  kcdTop = (kcdUser { classes.default = genMerge.mkIf true [ "x" ]; } [ ] [ ]).classes;
in
{
  kcdRead = {
    classes = kcdKind.classes;
    metadata = kcdKind.metadata;
    topServed = (builtins.tryEval (builtins.deepSeq kcdTop kcdTop)).success;
  };
}
