# `mixed-leaf-payload-partner-has-the-twin-answer` — den-hoag-1t2p5. One option is declared by a
# gen-merge LEAF (`int`, `bool`; bare, and under `listOf`) in one module and, in the other, by a raw
# foreign type keyed the same that STATES A PAYLOAD. nixpkgs asks only the later declaration's relation,
# and the mixed pair now has its nixpkgs twin's outcome in each order on both engines:
#  - `pay`, on nixpkgs' default relation, with a check refusing the value: refused in both orders (gen's
#    engine served it with the partner first, the partner's check dropped unsaid);
#  - `acc`, whose own relation joins a payload-free leaf of its name: served with gen first (that
#    relation decides), refused with the partner first (gen decides, as its twin does).
# The control: the `pay` partner stating no payload is served, as the twin serves it.
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
  leaves = {
    int = 7;
    bool = true;
  };
  partners = {
    pay =
      leaf:
      lib.mkOptionType {
        name = leaf;
        check = x: t.${leaf}.check x && x != leaves.${leaf};
        merge = lib.options.mergeEqualOption;
        functor = t.defaultFunctor leaf // {
          payload.strict = true;
          binOp = _a: _b: null;
        };
      };
    control =
      leaf:
      lib.mkOptionType {
        name = leaf;
        check = x: t.${leaf}.check x && x != leaves.${leaf};
        merge = lib.options.mergeEqualOption;
        functor = t.defaultFunctor leaf;
      };
    acc =
      leaf:
      let
        self = lib.mkOptionType {
          name = leaf;
          check = t.${leaf}.check;
          merge = lib.options.mergeEqualOption;
          functor = t.defaultFunctor leaf // {
            type = _: self;
            payload.refined = true;
            binOp = a: _b: a;
          };
          typeMerge =
            f':
            if f'.name == leaf && (f'.payload == null || f'.payload == { refined = true; }) then self else null;
        };
      in
      self;
  };
  # the outcome literal, [ gen-or-twin first, partner first ]
  want = {
    pay = [
      false
      false
    ];
    acc = [
      true
      false
    ];
    control = [
      true
      true
    ];
  };
  declare = type: { options.loom = lib.mkOption { inherit type; }; };
  served =
    eng: def: a: b:
    (builtins.tryEval (
      builtins.deepSeq
        (engines.${eng} [
          (declare a)
          (declare b)
          { loom = def; }
        ]).config.loom
        true
    )).success;
  rows =
    lib.concatMap
      (
        eng:
        lib.concatMap (
          leaf:
          lib.concatMap
            (
              shape:
              let
                wrapIn = lib': ty: if shape == "list" then lib'.listOf ty else ty;
                def = if shape == "list" then [ leaves.${leaf} ] else leaves.${leaf};
              in
              map (kind: {
                inherit kind eng def;
                p = wrapIn t (partners.${kind} leaf);
                gm = wrapIn g g.${leaf};
                np = wrapIn t t.${leaf};
              }) (lib.attrNames partners)
            )
            [
              "bare"
              "list"
            ]
        ) (lib.attrNames leaves)
      )
      [
        "gen"
        "ref"
      ];
  outcome = r: [
    (served r.eng r.def r.gm r.p)
    (served r.eng r.def r.p r.gm)
  ];
  twin = r: [
    (served r.eng r.def r.np r.p)
    (served r.eng r.def r.p r.np)
  ];
in
{
  construct = [ "mixed-leaf-payload-partner-has-the-twin-answer-in-each-order" ];
  check = asserts (lib.all (r: outcome r == twin r && outcome r == want.${r.kind}) rows);
}
