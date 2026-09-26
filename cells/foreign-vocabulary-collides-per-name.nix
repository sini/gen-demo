# `foreign-vocabulary-collides-per-name` — C71, den-hoag-m9r03. gen-merge built over a leaf
# vocabulary that shares ONE name, `nullOr`, with its strategies and does not declare it publishes
# every other name: `spool` typed by the vocabulary's own `str` reads `sateen`, gen-merge's `listOf`
# over it reads `[ "sateen" ]`, and `nullOr` answers with a refusal a caller can catch. It used to
# refuse the whole namespace, so every demand on `types` failed at a name it never touched.
{
  asserts,
  inputs,
  lib,
}:
let
  h = inputs.gen.inputs;
  over =
    types:
    import "${h.gen-merge}/lib" {
      prelude = h.gen-prelude.lib;
      inherit types;
      memo = h.gen-memo.lib;
      scope = h.gen-scope.lib;
    };
  gm = over { inherit (lib.types) str nullOr; };
  read =
    type: v:
    (gm.evalModuleTree {
      modules = [
        { options.spool = gm.mkOption { inherit type; }; }
        { spool = v; }
      ];
    }).config.spool;
in
{
  construct = [ "C71" ];
  check = asserts (
    read gm.types.str "sateen" == "sateen"
    && read (gm.types.listOf gm.types.str) [ "sateen" ] == [ "sateen" ]
    && !(builtins.tryEval gm.types.nullOr).success
  );
}
