# `nested-fanout-over-containment` — C198, den-hoag-8g2rn (rulings 7 and 13; the 8g2rn rulings S3c, T1
# and K-c; ADR-0010 §4(a), 0012 clauses 2–3, 0016 r5, 0026, 0029). A parametric include reached from
# inside an instance, needing a coordinate outside the instance's formals, fans out over the
# descendants of the entities the reading node binds. The descendants are DERIVED by gen-aspects from
# the entity graph's one-step `containment`, handed as data: loom `jacquard` contains the tassels `ta`,
# `tb` and `tc`, and `ta` and `tb` each contain a fringe. The loom's record declares one argument
# binding, `tension`, which its tassels inherit. `tc`'s containment edge carries a boundary mark, so
# no fan-out from the loom reaches it. The tassels' identifiers are not in their identity order, nor
# in the order the record literal writes them.
#
#   F1 one instance per unmarked tassel at the loom ({loom} ⊃ {tassel}), and {loom} ⊃ {loom, tassel}
#      the same, each tuple carrying the loom it sits under;
#   F2 the siblings in IDENTIFIER order (canonical, ruling 13), which the list merge realizes reversed;
#   F3 at each tassel's own node, only that tassel (S3c: the node's binding is bound before any
#      fan-out is tried);
#   F4 {loom} ⊃ {fringe} delivers no fringe at the loom: the fringes sit below the tassel level, which
#      a {fringe} aspect does not take (T1). Declined in the declared world, refused by name in the
#      open one. At a tassel's node, its own fringe;
#   F5 {loom} ⊃ {tassel, fringe} takes the tassel level, so it fans over the (tassel, fringe) pairs;
#   F6 the loom's `tension` reaches a per-tassel instance as the loom's binding (K-c);
#   F7 direct and static-hop packagings deliver the same at every node.
{
  asserts,
  genAlgebra,
  genAspects,
  genDelivery,
  genMerge,
  inputs,
}:
let
  hashIdentity = inputs.gen.lib.substrate.identity.hashIdentity;
  t = (genAlgebra.term hashIdentity).term;
  inherit (genAspects) guard pred;
  has = pred.has;
  cnfOf =
    declared:
    import ../aspect-cnf.nix
    // (
      if declared then
        {
          entityKinds = {
            loom = true;
            tassel = true;
            fringe = true;
            tension = false;
          };
        }
      else
        { }
    );
  # each pin includes the aspect its coordinate's value names
  pin =
    c: k:
    guard c {
      includes = [ (t.readCtx k [ ]) ];
    };
  defs = {
    pinT = pin (has "tassel") "tassel";
    pinF = pin (has "fringe") "fringe";
    pinTF = pin (pred.all [
      (has "tassel")
      (has "fringe")
    ]) "fringe";
    pinLT = pin (pred.all [
      (has "loom")
      (has "tassel")
    ]) "tassel";
    pinTT = pin (pred.all [
      (has "tassel")
      (has "tension")
    ]) "tension";
    hopT.includes = [ "pinT" ];
    loomT = guard (has "loom") { includes = [ "pinT" ]; };
    loomTS = guard (has "loom") { includes = [ "hopT" ]; };
    loomF = guard (has "loom") { includes = [ "pinF" ]; };
    loomTF = guard (has "loom") { includes = [ "pinTF" ]; };
    loomLT = guard (has "loom") { includes = [ "pinLT" ]; };
    loomTT = guard (has "loom") { includes = [ "pinTT" ]; };
  }
  // builtins.listToAttrs (
    map
      (v: {
        name = v;
        value.nixos.marks = [ v ];
      })
      [
        "v-ta"
        "v-tb"
        "v-tc"
        "v-fa"
        "v-fb"
        "v-taut"
      ]
  );
  aspectsOf =
    cnf:
    (genMerge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      { aspects = defs; }
    ]).config.aspects;
  entity = n: hashIdentity "entity" [ "name" ] (_: n);
  tension = hashIdentity "argument-binding" [ "name" ] (_: "jacquard-tension");
  # identifier → the entity whose identity it carries
  tassels = {
    tb = "fig";
    ta = "plum";
    tc = "quince";
  };
  suppliers = {
    ${entity "jacquard"}.loom = "v-jacquard";
    ${entity "plum"}.tassel = "v-ta";
    ${entity "fig"}.tassel = "v-tb";
    ${entity "quince"}.tassel = "v-tc";
    ${entity "sloe"}.fringe = "v-fa";
    ${entity "damson"}.fringe = "v-fb";
    ${tension}.tension = "v-taut";
  };
  rec0 = parent: key: x: {
    inherit parent key;
    identity = entity x;
    marked = false;
    bindings = { };
  };
  containment = {
    jacquard = rec0 null "loom" "jacquard" // {
      bindings.tension = tension;
    };
    tb = rec0 "jacquard" "tassel" tassels.tb;
    ta = rec0 "jacquard" "tassel" tassels.ta;
    tc = rec0 "jacquard" "tassel" tassels.tc // {
      marked = true;
    };
    fa = rec0 "ta" "fringe" "sloe";
    fb = rec0 "tb" "fringe" "damson";
  };
  nodeSources = {
    loom = {
      loom = entity "jacquard";
      inherit tension;
    };
    atA = nodeSources.loom // {
      tassel = entity tassels.ta;
    };
    atB = nodeSources.loom // {
      tassel = entity tassels.tb;
    };
  };
  # what `project` delivers at `nodes` reading `member`: each node's realized marks, unsorted
  run =
    {
      member,
      nodes ? builtins.attrNames nodeSources,
      declared ? true,
    }:
    let
      cnf = cnfOf declared;
      aspects = aspectsOf cnf;
      r = genAspects.instancesFor cnf aspects {
        inherit suppliers containment;
        scopes = builtins.listToAttrs (
          map (n: {
            name = n;
            value = {
              members = [ member ];
              sources = nodeSources.${n};
            };
          }) nodes
        );
      };
      p = genDelivery.project {
        values = {
          inherit aspects;
          hosts = builtins.listToAttrs (
            map (n: {
              name = n;
              value.aspects = [ member ];
            }) nodes
          );
        };
        inherit cnf;
        instances = r;
        selectNodes = v: v.hosts;
      };
    in
    {
      rel = r;
      marks = builtins.listToAttrs (
        map (n: {
          name = n;
          value =
            (genMerge.evalModuleTree { } (
              [ { freeformType = genMerge.types.lazyAttrsOf genMerge.types.anything; } ]
              ++ p.nodes.${n}.classes.nixos or [ ]
            )).config.marks or [ ];
        }) nodes
      );
    };
  refuses = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  loomT = run { member = "loomT"; };
  # the premise F2 discriminates on: the delivered tassels' identity order is the reverse of their
  # identifier order, so a list ordered by identity reads the other way
  identifierOrder = builtins.attrNames tassels;
  identityOrder = map (x: x.i) (
    builtins.sort (a: b: entity tassels.${a.i} < entity tassels.${b.i}) (
      map (i: { inherit i; }) identifierOrder
    )
  );
  f1 =
    builtins.length loomT.rel.reaches.loom.loomT == 1
    &&
      builtins.length (
        builtins.head (
          builtins.attrValues loomT.rel.nestedAt.loom.${builtins.head loomT.rel.reaches.loom.loomT}
        )
      ) == 2
    &&
      (run { member = "loomLT"; }).marks.loom == [
        "v-tb"
        "v-ta"
      ];
  f2 =
    builtins.filter (x: x != "tc") identityOrder == [
      "tb"
      "ta"
    ]
    &&
      loomT.marks.loom == [
        "v-tb"
        "v-ta"
      ];
  f3 = loomT.marks.atA == [ "v-ta" ] && loomT.marks.atB == [ "v-tb" ];
  f4 =
    let
      d = run { member = "loomF"; };
      dv = d.rel.declined.nestedAt.loom.${builtins.head d.rel.reaches.loom.loomF};
    in
    d.marks.loom == [ ]
    && dv == [ "pinF" ]
    && d.marks.atA == [ "v-fa" ]
    && d.marks.atB == [ "v-fb" ]
    &&
      refuses
        (run {
          member = "loomF";
          nodes = [ "loom" ];
          declared = false;
        }).marks.loom;
  f5 =
    (run { member = "loomTF"; }).marks == {
      loom = [
        "v-fb"
        "v-fa"
      ];
      atA = [ "v-fa" ];
      atB = [ "v-fb" ];
    };
  f6 =
    let
      d = run { member = "loomTT"; };
      kids = builtins.head (
        builtins.attrValues d.rel.nestedAt.loom.${builtins.head d.rel.reaches.loom.loomTT}
      );
    in
    builtins.length kids == 2
    && builtins.all (i: d.rel.vertices.${i}.formals.tension == tension) kids
    && d.marks.loom == [ "v-taut" ];
  f7 = (run { member = "loomTS"; }).marks == loomT.marks;
in
{
  construct = [ "C198" ];
  check = asserts (f1 && f2 && f3 && f4 && f5 && f6 && f7);
}
