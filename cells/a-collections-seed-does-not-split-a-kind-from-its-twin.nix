# `a-collections-seed-does-not-split-a-kind-from-its-twin` — den-hoag-isxgb. One kind declaration literal defining
# a kept collection, under two schemas that differ only in whether that collection declares `default = [ ]`, mints
# one mark (the kind's value is `[ "x" ]` either way), so its key must not split it either: nixpkgs'
# `lib.evalModules` keeps one of the pair exactly as it keeps one of the twin (the same literal under one schema,
# constructed twice), in both module orders, and gen's engine refuses both by name. The same holds where the kind
# defines the collection at that seed (`[ ]`). Under a key reading the seed's presence, nixpkgs composes both.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  T = genMerge.types;
  declOf = tags: {
    options.selvedge = genMerge.mkOption { type = T.listOf T.str; };
    config.selvedge = [ "k" ];
    inherit tags;
  };
  kindUnder =
    decl: tags:
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { collections = { inherit tags; }; }; }
      { config.schema.k = decl; }
    ]).config.schema.k;
  nixpkgs =
    a: b:
    (lib.evalModules {
      modules = [
        a
        b
      ];
    }).config.selvedge;
  genRefuses =
    a: b:
    !(builtins.tryEval (
      builtins.deepSeq
        (genMerge.evalModuleTree { } [
          a
          b
        ]).config.selvedge
        true
    )).success;
  agrees =
    value:
    let
      decl = declOf value;
      seeded = _: kindUnder decl { default = [ ]; };
      unseeded = kindUnder decl { };
      twin = nixpkgs (seeded 1) (seeded 2);
    in
    twin == [ "k" ]
    && nixpkgs unseeded (seeded 0) == twin
    && nixpkgs (seeded 0) unseeded == twin
    && genRefuses unseeded (seeded 0)
    && genRefuses (seeded 1) (seeded 2);
in
{
  construct = [ "a-collections-seed-does-not-split-a-kind-from-its-twin" ];
  check = asserts (agrees [ "x" ] && agrees [ ]);
}
