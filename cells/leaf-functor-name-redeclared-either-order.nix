# `leaf-functor-name-redeclared-either-order` — den-hoag-46zga. One option is declared by a nixpkgs
# leaf and by its gen-merge twin, which publishes another functor name or payload: gen-types'
# `string` is nixpkgs' `str`, and gen `path` is nixpkgs' `pathWith { absolute = true; }`. nixpkgs
# keys a redeclaration on the functor name and asserts the two payloads agree on null-ness, so the
# `str` pair refused in both orders on both engines, and the `path` pair served gen's record with
# nixpkgs first and aborted with gen first. gen-merge now publishes each under nixpkgs' name and
# payload (`interface.embeddings`) and joins a partner keyed there in the partner's own relation, so
# the option has its nixpkgs × nixpkgs twin's answer, record name included, in both orders on both
# engines. The closing case: nixpkgs' `pathInStore` beside gen `path` refuses in both orders on both
# engines, as its twin does; with nixpkgs declared first both engines served a non-store path there,
# the partner's check dropped. The control: gen × gen `str` keeps gen's record.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  g = genMerge.types;
  # the declared type's name and the value, or `null` where the pair refuses
  served =
    eval: mods:
    let
      r = builtins.tryEval (
        let
          o = eval mods;
          v = {
            inherit (o.options.loom.type) name;
            value = o.config.loom;
          };
        in
        builtins.deepSeq v v
      );
    in
    if r.success then r.value else null;
  engines = {
    gen = served (genMerge.evalModuleTree { });
    ref = served (modules: lib.evalModules { inherit modules; });
  };
  declare = type: { options.loom = lib.mkOption { inherit type; }; };
  orders = a: b: def: [
    [
      (declare a)
      (declare b)
      { loom = def; }
    ]
    [
      (declare b)
      (declare a)
      { loom = def; }
    ]
  ];
  pairs = {
    str = {
      np = t.str;
      gm = g.str;
      twin = t.str;
      def = "selvage";
    };
    path = {
      np = t.path;
      gm = g.path;
      twin = t.path;
      def = "/selvage";
    };
    inStore = {
      np = t.pathInStore;
      gm = g.path;
      twin = t.path;
      def = "/selvage";
    };
  };
  answers =
    eng: p: a:
    map engines.${eng} (orders p.np a p.def);
  sameAsTwin = eng: p: answers eng p p.gm == answers eng p p.twin;
  every =
    f:
    lib.all f [
      "gen"
      "ref"
    ];
  genGen = genMerge.evalModuleTree { } (builtins.head (orders g.str g.str "selvage"));
in
{
  construct = [
    "nixpkgs-leaf-and-its-gen-twin-under-another-functor-name-or-payload-serve-in-either-order"
  ];
  check = asserts (
    every (eng: sameAsTwin eng pairs.str && sameAsTwin eng pairs.path && sameAsTwin eng pairs.inStore)
    &&
      answers "gen" pairs.str pairs.str.gm == [
        {
          name = "str";
          value = "selvage";
        }
        {
          name = "str";
          value = "selvage";
        }
      ]
    && every (
      eng:
      answers eng pairs.inStore pairs.inStore.gm == [
        null
        null
      ]
    )
    && genGen.options.loom.type ? typeMergeRel
  );
}
