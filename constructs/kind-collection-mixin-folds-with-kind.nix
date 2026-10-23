# ── A MIXIN'S COLLECTION VALUE FOLDS WITH THE KIND'S OWN ──
# A `user` kind with one mixin: the mixin contributes `classes` elements carrying `mkIf true` and
# `mkDefault`, and `metadata.region = mkDefault "eu"`, while the kind itself defines
# `metadata.region = "us"`. The mixin's value is one more definition of the collection, after the
# kind's, so each element resolves as a `listOf` element does and the kind's plain `region` beats
# the mixin's `mkDefault` in one priority pool. A mixin contributing `classes` as a string is
# refused by name, a catchable refusal, where it once reached the list fold and aborted.
{ genMerge, inputs }:
let
  kcmSchema = inputs.gen.lib.substrate.schema;
  kcmUser =
    contribution: defs:
    (genMerge.evalModuleTree { } (
      [
        {
          options.schema = kcmSchema.mkSchemaOption {
            collections.classes.default = [ ];
            collections.metadata.default = { };
            baseModule = { };
            mixins = [ (kcmSchema.mkMixin { } (_: contribution)) ];
          };
        }
        { config.schema.user = { }; }
      ]
      ++ map (d: { config.schema.user = d; }) defs
    )).config.schema.user;
  kcmKind = kcmUser {
    classes = [
      (genMerge.mkIf true "nixos")
      (genMerge.mkDefault "darwin")
    ];
    metadata.region = genMerge.mkDefault "eu";
  } [ { metadata.region = "us"; } ];
  kcmWrongShape = (kcmUser { classes = genMerge.mkDefault "x"; } [ ]).classes;
in
{
  kcmRead = {
    classes = kcmKind.classes;
    metadata = kcmKind.metadata;
    wrongShapeServed = (builtins.tryEval (builtins.deepSeq kcmWrongShape kcmWrongShape)).success;
  };
}
