# `a-store-derivation-at-a-collections-seed-has-a-key` — den-hoag-1gb0t. A kind whose kept collection holds nixpkgs'
# `lib.toDerivation` value at the collection's seed (the seed and the value two DISTINCT `toDerivation` values, at the
# top, in a list and in a record) has a foreign key under pure evaluation, and nixpkgs' `lib.evalModules` keeps one of
# a twin by it. Before, the key decided "at the seed" by `==`, which forced `outPath` and so `builtins.storePath`,
# which pure evaluation refuses, and every arm here aborted uncatchably on every evaluator.
{
  asserts,
  genMerge,
  genSchema,
  inputs,
  lib,
}:
let
  T = genMerge.types;
  drv = _: lib.toDerivation inputs.nixpkgs.outPath;
  kindUnder =
    wrap:
    (genMerge.evalModuleTree { } [
      {
        options.schema = genSchema.mkSchemaOption {
          collections.tags = {
            merge = _: v: v;
            default = wrap (drv "seed");
          };
        };
      }
      {
        config.schema.k = {
          options.selvedge = genMerge.mkOption { type = T.listOf T.str; };
          config.selvedge = [ "k" ];
          tags = wrap (drv "value");
        };
      }
    ]).config.schema.k;
  keyOf =
    k:
    let
      key = (k.__functor k { }).key;
    in
    builtins.deepSeq key key;
  nixpkgs =
    a: b:
    (lib.evalModules {
      modules = [
        a
        b
      ];
    }).config.selvedge;
  holds =
    wrap:
    builtins.isString (keyOf (kindUnder wrap))
    && keyOf (kindUnder wrap) == keyOf (kindUnder wrap)
    && nixpkgs (kindUnder wrap) (kindUnder wrap) == [ "k" ];
in
{
  construct = [ "a-store-derivation-at-a-collections-seed-has-a-key" ];
  check = asserts (
    holds (d: d)
    && holds (d: [ d ])
    && holds (d: {
      p = d;
    })
  );
}
