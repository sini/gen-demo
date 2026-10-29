# `a-parentless-kind-reached-twice-composes-once` — den-hoag-obd03. A parentless kind `ground` reached by
# `twill` directly and through `satin` (a diamond) is one construction, so it composes once in gen's engine
# and in nixpkgs' `lib.evalModules` alike: `selvedge` holds each kind's entry once. Every kind is keyed by its
# declaration node (gen) and by its reference key (nixpkgs dedups by it). It used to compose twice in both.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  schema =
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { }; }
      (
        { config, ... }:
        {
          config.schema = {
            ground = {
              options.selvedge = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; };
              config.selvedge = [ "ground" ];
            };
            satin = {
              inherits = [ config.schema.ground ];
              config.selvedge = [ "satin" ];
            };
            twill = {
              inherits = [
                config.schema.ground
                config.schema.satin
              ];
              config.selvedge = [ "twill" ];
            };
          };
        }
      )
    ]).config.schema;
  sorted = builtins.sort builtins.lessThan;
  want = [
    "ground"
    "satin"
    "twill"
  ];
in
{
  construct = [ "a-parentless-kind-reached-twice-composes-once" ];
  check = asserts (
    sorted (genMerge.evalModuleTree { } [ schema.twill ]).config.selvedge == want
    && sorted (lib.evalModules { modules = [ schema.twill ]; }).config.selvedge == want
  );
}
