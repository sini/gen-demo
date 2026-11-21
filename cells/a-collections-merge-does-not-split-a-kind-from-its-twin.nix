# `a-collections-merge-does-not-split-a-kind-from-its-twin` — den-hoag-t7pc7. One kind declaration literal
# under two schemas that differ only in a kept collection's `merge`, which the kind does not define, mints one
# mark, so its key must not split it either: nixpkgs' `lib.evalModules` keeps one of the pair exactly as it keeps
# one of the twin (the same literal under one schema, constructed twice), in both module orders, and gen's engine
# refuses both by name. Under a key carrying the `merge` presence bit, nixpkgs composes both of the pair.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  T = genMerge.types;
  decl = {
    options.selvedge = genMerge.mkOption { type = T.listOf T.str; };
    config.selvedge = [ "k" ];
  };
  kindUnder =
    tags:
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { collections = { inherit tags; }; }; }
      { config.schema.k = decl; }
    ]).config.schema.k;
  withMerge = kindUnder {
    default = [ ];
    merge = acc: v: acc ++ v;
  };
  plain = _: kindUnder { default = [ ]; };
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
  twin = nixpkgs (plain 1) (plain 2);
in
{
  construct = [ "a-collections-merge-does-not-split-a-kind-from-its-twin" ];
  check = asserts (
    twin == [ "k" ]
    && nixpkgs withMerge (plain 0) == twin
    && nixpkgs (plain 0) withMerge == twin
    && genRefuses withMerge (plain 0)
    && genRefuses (plain 1) (plain 2)
  );
}
