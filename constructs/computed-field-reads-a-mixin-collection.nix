# `computed-field-reads-a-mixin-collection`: a schema mixin contributes a `tags` value to `host`,
# beside `host`'s own, and the schema's `computed` hook reads the collection back as `tagged`; a twin
# tree writes the mixin's value on the kind itself and carries no mixin.

{ genMerge, genSchema }:

let
  strOpt =
    d:
    genMerge.mkOption {
      type = genMerge.types.str;
      default = d;
    };
  tagsTree =
    mixins: extra:
    (genMerge.evalModuleTree { } (
      [
        {
          options.schema = genSchema.mkSchemaOption {
            collections.tags = {
              default = [ ];
            };
            baseModule = { };
            computed = collections: _: { tagged = collections.tags; };
            inherit mixins;
          };
        }
        {
          config.schema.host = {
            options.hostName = strOpt "h";
            tags = [ "web" ];
          };
        }
      ]
      ++ extra
    )).config.schema;
in

{
  hostByMixinTags =
    tagsTree
      [
        (genSchema.mkMixin { name = "monitored"; } (_: {
          tags = [ "monitored" ];
        }))
      ]
      [ ];
  hostByKindTags = tagsTree [ ] [ { config.schema.host.tags = [ "monitored" ]; } ];
}
