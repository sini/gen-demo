# `redeclared-type-clash-refuses-only-its-own-read` — den-hoag-q36zi (ADR-0039 serve half). One option
# `loom` is declared `int` in one module and `str` in another, beside an unrelated option `weft`. nixpkgs
# merges a redeclaration's types when THAT option is read, so `config.weft` and `options.weft` serve and
# only a read of `loom` refuses. gen-merge refused the whole evaluation: its value fold's key walk forced
# every leaf's merged declaration, so `config.weft` read the type-clash refusal. Each engine's answer per
# read is pinned, and the two engines agree: `weft` served, `loom` refused by name, catchably, at its
# value, its descriptor and its type. Red where `weft` reads a refusal, or where `loom` serves.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  mods = [
    { options.loom = lib.mkOption { type = t.int; }; }
    { options.loom = lib.mkOption { type = t.str; }; }
    {
      options.weft = lib.mkOption {
        type = t.str;
        default = "selvage";
      };
    }
    { loom = 1; }
  ];
  answer =
    v:
    let
      r = builtins.tryEval (builtins.deepSeq v v);
    in
    if r.success then r.value else "REFUSED";
  reads = o: {
    weft = answer o.config.weft;
    weftDefault = answer o.options.weft.default;
    loom = answer o.config.loom;
    loomOption = answer (builtins.seq o.options.loom null);
    loomType = answer o.options.loom.type.name;
  };
  expected = {
    weft = "selvage";
    weftDefault = "selvage";
    loom = "REFUSED";
    loomOption = "REFUSED";
    loomType = "REFUSED";
  };
in
{
  construct = [
    "a-redeclaration-whose-types-do-not-merge-refuses-only-the-read-of-that-option"
  ];
  check = asserts (
    reads (genMerge.evalModuleTree { } mods) == expected
    && reads (lib.evalModules { modules = mods; }) == expected
  );
}
