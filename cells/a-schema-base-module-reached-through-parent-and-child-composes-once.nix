# `a-schema-base-module-reached-through-parent-and-child-composes-once` — xh14j K2 (b). A schema's plain
# `baseModule` declares a defaulted `pattern`; `twill` inherits `ground`, so the base reaches `twill` through
# `ground` and through `twill` itself. It is one construction (keyed by its declaration node, sealed by its
# value), so it composes once in gen's engine and in nixpkgs' `lib.evalModules`: `pattern` reads its default
# and `selvedge` holds the base's entry once. Before, the doubled `pattern` declaration was two unkeyed
# modules, both stating `default`.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  str =
    d:
    genMerge.mkOption {
      type = genMerge.types.str;
      default = d;
    };
  schema =
    (genMerge.evalModuleTree { } [
      {
        options.schema = genSchema.mkSchemaOption {
          baseModule = {
            options.pattern = str "herringbone";
            options.selvedge = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; };
            config.selvedge = [ "base" ];
          };
        };
      }
      { config.schema.ground.options.ply = str "two"; }
      {
        config.schema.twill = {
          options.wale = str "fine";
          inherits = [ "ground" ];
        };
      }
    ]).config.schema;
  c = (genMerge.evalModuleTree { } [ schema.twill ]).config;
  n = (lib.evalModules { modules = [ schema.twill ]; }).config;
in
{
  construct = [ "kind-inheritance-resolves-a-value" ];
  check = asserts (
    c.pattern == "herringbone"
    && c.selvedge == [ "base" ]
    && c.ply == "two"
    && n.pattern == "herringbone"
    && n.selvedge == [ "base" ]
  );
}
