# `a-guarded-kind-reached-through-parent-and-child-composes-once` — xh14j. The schema keeps `collections.excludes`
# in identity and `ground` defines it, so `ground` is decided at one declaration node by its construction token,
# never by minting over `excludes` (which may read an instance under construction). `twill` reaches `ground`
# directly and through `satin`: one construction on two paths, one module, on every evaluator, in gen's engine
# and in nixpkgs' `lib.evalModules`. Beside it, the same kind built twice from one declaration (two trees) meets at
# one node and is refused by name, so a token that called every pair equal cannot pass.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  T = genMerge.types;
  treeOf =
    _:
    (genMerge.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = genSchema.mkSchemaOption {
            collections.excludes = {
              default = [ ];
              merge = acc: v: acc ++ v;
            };
          };
          config.schema = {
            ground = {
              excludes = [ "nap" ];
              options.selvedge = genMerge.mkOption { type = T.listOf T.str; };
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
  schema = treeOf 0;
  sorted = builtins.sort builtins.lessThan;
  want = [
    "ground"
    "satin"
    "twill"
  ];
  twoConstructions = builtins.tryEval (
    builtins.deepSeq
      (genMerge.evalModuleTree { } [
        (treeOf 1).ground
        (treeOf 2).ground
      ]).config.selvedge
      true
  );
in
{
  construct = [ "a-guarded-kind-reached-through-parent-and-child-composes-once" ];
  check = asserts (
    sorted (genMerge.evalModuleTree { } [ schema.twill ]).config.selvedge == want
    && sorted (lib.evalModules { modules = [ schema.twill ]; }).config.selvedge == want
    && !twoConstructions.success
  );
}
