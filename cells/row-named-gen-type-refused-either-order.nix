# `row-named-gen-type-refused-either-order` — den-hoag-n8cpq. One option is declared by a gen type
# whose caller-chosen NAME is an embedding row's (`enum "path"`, a `defineType` named `string`) and
# by that row's nixpkgs type. gen-merge reached its embedding rows by the type's name, so the gen
# type borrowed the row: `enum "path" [ "/selvage" ]` beside nixpkgs' `path` served `"/bobbin"` with
# nixpkgs declared first, the enum's membership dropped, and the `defineType` named `string` beside
# `str` served a value its own check refuses. Every row is now stated by the gen-merge constructor
# that builds the type, never by a name, so each pair has its nixpkgs × nixpkgs twin's answer (a
# nixpkgs type of that name and check) in both orders on both engines: refused. The closing case:
# gen `path` beside nixpkgs' `path` still reaches its row and serves, as its twin does.
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
    enumPath = {
      np = t.path;
      gm = g.enum "path" [ "/selvage" ];
      twin = t.enum [ "/selvage" ];
      def = "/bobbin";
    };
    definedStr = {
      np = t.str;
      gm = g.defineType {
        name = "string";
        verify = x: if x == "selvage" then null else "not selvage";
      };
      twin = lib.mkOptionType {
        name = "string";
        check = x: x == "selvage";
        merge = lib.options.mergeEqualOption;
      };
      def = "bobbin";
    };
    closing = {
      np = t.path;
      gm = g.path;
      twin = t.path;
      def = "/bobbin";
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
in
{
  construct = [
    "gen-type-named-like-an-embedding-row-is-refused-beside-that-rows-nixpkgs-type-in-either-order-as-its-twin-is"
  ];
  check = asserts (
    every (
      eng:
      sameAsTwin eng pairs.enumPath && sameAsTwin eng pairs.definedStr && sameAsTwin eng pairs.closing
    )
    && every (
      eng:
      answers eng pairs.enumPath pairs.enumPath.gm == [
        null
        null
      ]
      &&
        answers eng pairs.definedStr pairs.definedStr.gm == [
          null
          null
        ]
    )
    && every (eng: lib.all (a: a != null) (answers eng pairs.closing pairs.closing.gm))
  );
}
