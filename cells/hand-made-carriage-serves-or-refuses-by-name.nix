# `hand-made-carriage-serves-or-refuses-by-name` — den-hoag-l4bv5. A gen `attrsOf` copied with a `carries` stated by
# hand, as the element of a gen `attrsOf`. Stating one alternative and no element, the copy does not forward: its own
# substructure, which its fold reads, is its answer, and nixpkgs' `lib.evalModules` serves the twin's value. Stating a
# `carries` that is no attribute set, it is refused by name, catchably, in gen's engine, where it has no answer of its
# own. The unforged copy is the control. Each forged shape used to abort uncatchably on the field it read.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  nt = lib.types;
  sub = mkOption: int: {
    options.a = mkOption {
      type = int;
      default = 0;
    };
    options.b = mkOption {
      type = int;
      default = 0;
    };
  };
  gsub = t.submodule (sub genMerge.mkOption t.int);
  v = {
    k.j.a = 1;
  };
  np =
    type:
    (lib.evalModules {
      modules = [
        { options.spool = lib.mkOption { inherit type; }; }
        { spool = v; }
      ];
    }).config.spool;
  gen =
    type:
    (genMerge.evalModuleTree { } [
      { options.spool = genMerge.mkOption { inherit type; }; }
      { spool = v; }
    ]).config.spool;
  try = e: builtins.tryEval (builtins.deepSeq e e);
  twin = np (nt.attrsOf (nt.attrsOf (nt.submodule (sub lib.mkOption nt.int))));
  served = r: r.success && r.value == twin;
in
{
  construct = [
    "a-hand-made-carriage-is-served-where-the-record-answers-and-refused-by-name-where-it-does-not"
  ];
  check = asserts (
    twin == {
      k.j = {
        a = 1;
        b = 0;
      };
    }
    && served (try (np (t.attrsOf (t.attrsOf gsub // { carries.alternatives = [ gsub ]; }))))
    && !(try (gen (t.attrsOf (t.attrsOf gsub // { carries = 5; })))).success
    && served (try (np (t.attrsOf (t.attrsOf gsub))))
  );
}
