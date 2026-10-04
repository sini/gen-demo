# `mixed-leaf-redeclared-record` — C183, den-hoag-x4j3w. One option is declared by a nixpkgs LEAF
# (`int`, `bool`, `float`, `raw`, `anything`; bare, and under `listOf`) in one module and by its
# gen-merge twin in the other. The value was nixpkgs' in every order; the declared TYPE was not: its
# record was gen's or nixpkgs' by which declaration came first (a gen record states `typeMergeRel`, a
# nixpkgs one does not; a `carries` test never reads a gen leaf). A gen leaf facing a raw foreign leaf
# of the same name now answers the record that partner's functor names, so `options.loom.type` and
# every `nestedTypes` level below it is a nixpkgs record in both orders on both engines, as for the
# nixpkgs × nixpkgs twin. The control: a gen × gen pair keeps its gen record.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  g = genMerge.types;
  engines = {
    gen = modules: genMerge.evalModuleTree { } modules;
    ref = modules: lib.evalModules { inherit modules; };
  };
  # whose record each level of the declared type is: `G` states `typeMergeRel`, `N` does not
  sig =
    ty:
    (if ty ? typeMergeRel then "G" else "N")
    + (
      if ty ? nestedTypes then
        "("
        + lib.concatStringsSep "," (map (k: sig ty.nestedTypes.${k}) (lib.attrNames ty.nestedTypes))
        + ")"
      else
        ""
    );
  declare = type: { options.loom = lib.mkOption { inherit type; }; };
  read =
    eng: def: a: b:
    let
      r = engines.${eng} [
        (declare a)
        (declare b)
        { loom = def; }
      ];
    in
    {
      spine = sig r.options.loom.type;
      value = r.config.loom;
    };
  leaves = {
    int = 1;
    bool = true;
    float = 1.5;
    raw = 1;
    anything = 1;
  };
  shapes = {
    bare = {
      def = v: v;
    };
    list = {
      def = v: [ v ];
    };
  };
  cell =
    eng: leaf: shape:
    let
      s = shapes.${shape};
      wrapIn = lib': ty: if shape == "list" then lib'.listOf ty else ty;
      np = wrapIn t t.${leaf};
      gm = wrapIn g g.${leaf};
      def = s.def leaves.${leaf};
    in
    {
      mixed = [
        (read eng def np gm)
        (read eng def gm np)
      ];
      twin = read eng def np np;
      gg = read "gen" def gm gm;
    };
  rows =
    lib.concatMap
      (
        eng:
        lib.concatMap (
          leaf:
          map (shape: cell eng leaf shape) [
            "bare"
            "list"
          ]
        ) (lib.attrNames leaves)
      )
      [
        "gen"
        "ref"
      ];
in
{
  construct = [ "C183" ];
  check = asserts (
    lib.all (c: lib.all (r: r == c.twin) c.mixed && !(lib.hasInfix "G" c.twin.spine)) rows
    && lib.all (c: lib.hasInfix "G" c.gg.spine) rows
  );
}
