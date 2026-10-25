# `kind-parent-declared-by-a-mixin`: a schema mixin gives `host` a parent kind from another tree
# (`audited`), and a twin tree declares the same parent on the kind itself, the subjects of
# gen-schema's parent walk over a mixin-declared parent.

{ genMerge, genSchema }:

let
  strOpt =
    d:
    genMerge.mkOption {
      type = genMerge.types.str;
      default = d;
    };
  audited =
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { }; }
      { config.schema.audited.options.auditLog = strOpt "/var/log/audit"; }
    ]).config.schema.audited;
  hostTree =
    schemaArgs: hostDecl:
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption schemaArgs; }
      {
        config.schema.host = {
          options.hostName = strOpt "h";
        }
        // hostDecl;
      }
    ]).config.schema;
in

{
  auditedKind = audited;
  hostByMixinParent = hostTree {
    baseModule = { };
    mixins = [
      (genSchema.mkMixin { name = "audit"; } (_: {
        inherits = [ audited ];
      }))
    ];
  } { };
  hostByKindParent = hostTree { baseModule = { }; } { inherits = [ audited ]; };
}
