# `number-redeclared-either-order` — den-hoag-kawe8. One option is declared by nixpkgs' `number`,
# which IS `either int float`, and by gen-merge's `number`, one gen-types leaf. With no row for it,
# gen's `number` published its own name with no payload, so the pair refused in both orders on both
# engines. gen-merge now publishes it under nixpkgs' `either` over its own `int` and `float`
# (`interface.embeddings`, a row whose parameters are types) and joins a partner keyed there in that
# partner's union relation, so the option has its nixpkgs × nixpkgs twin's answer, record name
# included, in both orders on both engines, and inside a union (`either number str`). The closing
# cases: a string, which neither declaration admits, refuses in both orders on both engines, as its
# twin does; and a value a nixpkgs `addCheck` around nixpkgs' `number` rejects refuses in gen's
# evaluation in both orders, the wrapper's check kept (the meet). The control: gen × gen `number`
# keeps gen's record.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  g = genMerge.types;
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
    int = {
      np = t.number;
      gm = g.number;
      twin = t.number;
      def = 1;
    };
    float = {
      np = t.number;
      gm = g.number;
      twin = t.number;
      def = 1.5;
    };
    union = {
      np = t.either t.number t.str;
      gm = g.either g.number g.str;
      twin = t.either t.number t.str;
      def = 1;
    };
    # a nixpkgs check wrapped around nixpkgs' `number`, rejecting a value both `number`s admit
    wrapped = {
      np = t.addCheck t.number (v: v != 7);
      gm = g.number;
      twin = t.number;
      def = 7;
    };
    neither = {
      np = t.number;
      gm = g.number;
      twin = t.number;
      def = "selvage";
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
  genGen = genMerge.evalModuleTree { } (builtins.head (orders g.number g.number 1));
in
{
  construct = [
    "nixpkgs-number-and-gen-number-serve-in-either-order"
  ];
  check = asserts (
    every (
      eng:
      sameAsTwin eng pairs.int
      && sameAsTwin eng pairs.float
      && sameAsTwin eng pairs.union
      && sameAsTwin eng pairs.neither
    )
    && every (
      eng:
      answers eng pairs.float pairs.float.gm == [
        {
          name = "either";
          value = 1.5;
        }
        {
          name = "either";
          value = 1.5;
        }
      ]
    )
    && every (
      eng:
      answers eng pairs.neither pairs.neither.gm == [
        null
        null
      ]
    )
    # the wrapper's check is kept in gen's own evaluation (ADR-0039, the meet): refused in both orders
    &&
      answers "gen" pairs.wrapped pairs.wrapped.gm == [
        null
        null
      ]
    && genGen.options.loom.type ? typeMergeRel
    && genGen.options.loom.type.name == "number"
  );
}
