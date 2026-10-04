# `aspect-instantiation-edge` — C176, den-hoag-bgeum (ADR-0010 §4(a); van Antwerpen 2018 §2.5).
# An instance of a parametric aspect points at its declaration by an `instantiates` edge (vA's `I`
# edge), the declaration's members stay reachable through it without firing it, and the substitution
# is applied to each field where the field is read. Declared in the corpus's grammar under
# `entityKinds = { loom = true; shuttle = true; }`, read through gen-aspects' `instancesFor`, every
# context derived from a literal `suppliers` map.
#
# Each limb names the spec's §3a cell it carries:
#   D1 (A1, A11) `selvage` delivers a `nixos` class key beside `trim`, a member whose projection path
#      is missing: the class key reads through `reaches` and the entry, and `trim` refuses only at its
#      own read (before, the whole entry and the relation's edges refused with it);
#   D2 (A8) gen-scope `resolve` over `instantiates · includes`, from `selvage`'s instance, answers the
#      declaration's resolved members, `pick` and `hem`; `includes` from static `frame` is the control;
#   D3 (A9, gate C3) path consistency: along every nested edge the child's substitution restricts its
#      parent's. Live: nested edges exist, and `heddle`, which reads `shuttle` (supplied by the scope,
#      not read by its parent `selvage`), has no nested edge at `selvage`'s narrowed tuple while the
#      scope reaching it directly mints it.
{
  asserts,
  genAlgebra,
  genAspects,
  genMerge,
  genScope,
  inputs,
}:
let
  cnf = import ../aspect-cnf.nix // {
    entityKinds = {
      loom = true;
      shuttle = true;
    };
  };
  t = (genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity).term;
  inherit (genAspects) guard pred;
  aspects =
    (genMerge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      {
        aspects = {
          frame.includes = [ "selvage" ];
          selvage = guard (pred.has "loom") {
            nixos.marks = [ "selvage" ];
            trim = t.readCtx "loom" [ "deep" ];
            includes = [
              "pick"
              "hem"
              "heddle"
            ];
          };
          pick = guard (pred.has "loom") {
            description = t.concat [
              (t.lit "pick-")
              (t.readCtx "loom" [ ])
            ];
          };
          hem.description = "hem";
          heddle = guard (pred.all [
            (pred.has "loom")
            (pred.has "shuttle")
          ]) { description = t.readCtx "shuttle" [ ]; };
        };
      }
    ]).config.aspects;

  entity = n: inputs.gen.lib.substrate.identity.hashIdentity "entity" [ "name" ] (_: n);
  suppliers = {
    ${entity "jacquard"}.loom = "jacquard";
    ${entity "fly"}.shuttle = "fly";
  };
  sources = {
    loom = entity "jacquard";
    shuttle = entity "fly";
  };
  r = genAspects.instancesFor cnf aspects {
    inherit suppliers;
    scopes = {
      warp = {
        members = [ "frame" ];
        inherit sources;
      };
      weft = {
        members = [ "heddle" ];
        inherit sources;
      };
    };
  };
  facts = genAspects.graphFacts cnf aspects;
  refuses = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  selvageI = builtins.head r.reaches.warp.selvage;

  d1 =
    map (i: r.vertices.${i}.entry.nixos.marks) r.reaches.warp.selvage == [ [ "selvage" ] ]
    && refuses r.vertices.${selvageI}.entry.trim
    && builtins.attrNames r.nested.${selvageI} == [ "pick" ];

  # The instances and the declarations as one EVALUATED SCOPE: each edge label `l` is the attribute
  # `edges-l` gen-scope's resolution calculus reads, and every node declares its marks, none.
  scope =
    genScope.eval { parseParent = _: null; }
      {
        children = _: _: { };
        marks = _: _: [ ];
        edges-instantiates = _: id: r.instantiates.${id} or [ ];
        edges-includes = _: id: facts.includesOf.${id} or [ ];
      }
      (
        genScope.buildRoots {
          parentGraph = genScope.vertices (builtins.attrNames r.vertices ++ facts.nodes);
        }
      );
  walk =
    from: expression:
    builtins.sort builtins.lessThan (
      map (a: a.node)
        (genScope.resolve {
          wf = genScope.wellFormed {
            alphabet = [
              "instantiates"
              "includes"
            ];
            inherit expression;
          };
          dataFilter = _: true;
        } scope from).answers
    );
  rx = genScope.wfl;
  d2 =
    walk selvageI (rx.lit "instantiates") == [ "selvage" ]
    &&
      walk selvageI (
        rx.seq [
          (rx.lit "instantiates")
          (rx.lit "includes")
        ]
      ) == [
        "heddle"
        "hem"
        "pick"
      ]
    && walk "frame" (rx.lit "includes") == [ "selvage" ];

  pairs = builtins.concatMap (
    p:
    map (c: {
      pf = r.vertices.${p}.formals;
      cf = r.vertices.${c}.formals;
    }) (builtins.concatLists (builtins.attrValues r.nested.${p}))
  ) (builtins.attrNames r.nested);
  d3 =
    builtins.length pairs > 0
    && builtins.all (
      x: builtins.intersectAttrs x.pf x.cf == x.cf && builtins.intersectAttrs x.cf x.pf == x.cf
    ) pairs
    && !(r.nested.${selvageI} ? heddle)
    && map (i: r.vertices.${i}.entry.description) r.reaches.weft.heddle == [ "fly" ];
in
{
  construct = [ "C176" ];
  check = asserts (d1 && d2 && d3);
}
