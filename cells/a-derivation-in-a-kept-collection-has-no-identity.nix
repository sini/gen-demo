# `a-derivation-in-a-kept-collection-has-no-identity` — den-hoag-5x8xu. nixpkgs' `lib.toDerivation` builds a
# derivation with `type = "derivation"` and `outPath` and no `drvPath`, which Nix `==` compares by `outPath` alone.
# The hub's one mint refuses it by name, directly and inside a list, without forcing `outPath`. A kind holding it in
# a kept collection, at the collection's seed and away from it, still has a mark (the refused value is sealed in
# it, not walked), and away from the seed its foreign key lets nixpkgs' `lib.evalModules` keep one of a twin. Before,
# the mint walked the value, forced its `name` and so `builtins.storePath`, which pure evaluation refuses, and every
# arm here aborted uncatchably.
#
# Not read: the key at the seed (den-hoag-1gb0t). It decides "at the seed" by `==`, which forces `outPath`, so it
# aborts under pure evaluation on main, and under this gate for two distinct values on every evaluator.
# (For this cell's one shared value, Lix under this gate does not abort; Nix and Determinate do.)
{
  asserts,
  genMerge,
  genSchema,
  inputs,
  lib,
}:
let
  T = genMerge.types;
  mint = inputs.gen.lib.substrate.identity.hashIdentity;
  drv = lib.toDerivation inputs.nixpkgs.outPath;
  ok = e: (builtins.tryEval (builtins.deepSeq e e)).success;
  kindUnder =
    seed:
    (genMerge.evalModuleTree { } [
      {
        options.schema = genSchema.mkSchemaOption {
          collections.tags = {
            merge = _: v: v;
            default = seed;
          };
        };
      }
      {
        config.schema.k = {
          options.selvedge = genMerge.mkOption { type = T.listOf T.str; };
          config.selvedge = [ "k" ];
          tags = drv;
        };
      }
    ]).config.schema.k;
  atSeed = _: kindUnder drv;
  away = _: kindUnder 7;
  nixpkgs =
    a: b:
    (lib.evalModules {
      modules = [
        a
        b
      ];
    }).config.selvedge;
in
{
  construct = [ "a-derivation-in-a-kept-collection-has-no-identity" ];
  check = asserts (
    !ok (mint "k" [ "x" ] (_: drv))
    && !ok (mint "k" [ "x" ] (_: [ drv ]))
    && ok (atSeed 1).__mint.minted
    && (atSeed 1).__mint.minted == (atSeed 2).__mint.minted
    && ok (away 1).__mint.minted
    && nixpkgs (away 1) (away 2) == [ "k" ]
  );
}
