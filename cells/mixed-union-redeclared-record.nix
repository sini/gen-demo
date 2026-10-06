# `mixed-union-redeclared-record` — C179, den-hoag-zcufn. One option is declared by a nixpkgs
# `either int bool` (or `oneOf [ int bool (listOf int) ]`) in one module and by its gen-merge twin in
# the other. nixpkgs' `either` states its relation in an overridden `typeMerge`, so its functor does
# not carry it: nixpkgs' engine refused the pair when nixpkgs' declaration came first, and gen's
# engine built a gen record. gen's `either` now rebuilds the partner from its published functor and
# asks the rebuilt record's relation, so `options.loom.type` and every member below it is a nixpkgs
# record in both orders on both engines, as for the nixpkgs × nixpkgs twin, with the twin's value.
# `sig` reads `typeMergeRel`, which a gen LEAF states too (a `carries` test is blind at the leaf).
# The control: a gen × gen pair keeps its gen record at every level.
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
    let
      n = ty.nestedTypes or { };
      kids = lib.filter (
        k:
        lib.elem k [
          "left"
          "right"
          "elemType"
        ]
      ) (lib.attrNames n);
    in
    (if ty ? typeMergeRel then "G" else "N")
    + (if kids == [ ] then "" else "(" + lib.concatStringsSep "," (map (k: sig n.${k}) kids) + ")");
  declare = type: { options.loom = lib.mkOption { inherit type; }; };
  read =
    eng: a: b:
    let
      r = engines.${eng} [
        (declare a)
        (declare b)
        { loom = 1; }
      ];
      tried = builtins.tryEval (builtins.deepSeq r.config.loom (sig r.options.loom.type));
    in
    if tried.success then
      {
        spine = tried.value;
        value = r.config.loom;
      }
    else
      "REFUSED";
  shapes = lib: {
    union = lib.either lib.int lib.bool;
    oneOf = lib.oneOf [
      lib.int
      lib.bool
      (lib.listOf lib.int)
    ];
  };
  npS = shapes t;
  gmS = shapes g;
  mixed = eng: k: [
    (read eng npS.${k} gmS.${k})
    (read eng gmS.${k} npS.${k})
  ];
  twin = eng: k: read eng npS.${k} npS.${k};
  nppOnly = eng: k: twin eng k != "REFUSED" && lib.all (r: r == twin eng k) (mixed eng k);
  gg = read "gen" gmS.union gmS.union;
in
{
  construct = [ "mixed-union-redeclaration-has-nixpkgs-declared-type-record-in-either-order" ];
  check = asserts (
    lib.all
      (
        eng:
        lib.all (k: nppOnly eng k) [
          "union"
          "oneOf"
        ]
      )
      [
        "gen"
        "ref"
      ]
    && gg != "REFUSED"
    && gg.spine == "G(G,G)"
    && (twin "gen" "union").spine == "N(N,N)"
    && gg.value == 1
  );
}
