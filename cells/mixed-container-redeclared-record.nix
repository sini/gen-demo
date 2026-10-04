# `mixed-container-redeclared-record` — C170, den-hoag-zvidt. One option is declared by a nixpkgs
# `listOf` (or `nullOr (listOf …)`) in one module and by its gen-merge twin in the other. The value
# was nixpkgs' in every order; the declared TYPE was not: its record was gen's or nixpkgs' by which
# declaration came first (a gen record states `typeMergeRel`, a nixpkgs one does not). The partner's own
# relation now decides the pair, so `options.loom.type` and every `nestedTypes` level below it is a
# nixpkgs record in both orders on both engines, as for the nixpkgs × nixpkgs twin. The control: a
# gen × gen pair keeps its gen record at every level.
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
    eng: a: b:
    let
      r = engines.${eng} [
        (declare a)
        (declare b)
        { loom = [ 1 ]; }
      ];
    in
    {
      spine = sig r.options.loom.type;
      value = r.config.loom;
    };
  shapes = lib: {
    list = lib.listOf lib.int;
    nullList = lib.nullOr (lib.listOf lib.int);
  };
  npS = shapes t;
  gmS = shapes g;
  mixed = eng: k: [
    (read eng npS.${k} gmS.${k})
    (read eng gmS.${k} npS.${k})
  ];
  twin = eng: k: read eng npS.${k} npS.${k};
  nppOnly = eng: k: lib.all (r: r == twin eng k) (mixed eng k);
  gg = read "gen" gmS.list gmS.list;
in
{
  construct = [ "C170" ];
  check = asserts (
    lib.all
      (
        eng:
        lib.all (k: nppOnly eng k) [
          "list"
          "nullList"
        ]
      )
      [
        "gen"
        "ref"
      ]
    && lib.hasInfix "G" gg.spine
    && !(lib.hasInfix "G" (twin "gen" "list").spine)
    && gg.value == [ 1 ]
  );
}
