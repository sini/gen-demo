# ── C186 — shared instances under the delivery-class map (den-hoag-htfv3 U4; ADR-0010 §4(a), ADR-0028).
# C118's nodes, map and terminals, now with parametric content: `tuck` reads `bolt`, one per loom,
# and its include names that loom's own pleat; `hem` reads `weave`, one binding per pin, so `godet`
# and `jabot` (pin `batiste`) reach ONE `hem` vertex. gen-aspects' `instancesFor` mints, gen-delivery's
# `project` reads the relation through C118's `couchingPinMap`, and each delivery class realizes
# through C118's REAL `mkHostedTerminal` over stock `lib.evalModules`.
#
# The cold arm (design §4 cell 1, the direct-member domain): each parametric P a loom lists becomes
# the static `P-<loom>`, P applied at that loom's tuple through gen-aspects' own `instanceOf`, named
# in P's place. `flounce` is kept out of it: it reaches `fringe` by fan-out, one sibling per tassel
# its loom contains (`containment`, den-hoag-8g2rn), under its own projection.
{
  genAlgebra,
  genAspects,
  genDelivery,
  genMerge,
  inputs,
  couchingPinMap,
  couchingTerminals,
}:
let
  cnf.keySemantics.couching.category = "class";
  t = (genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity).term;
  inherit (genAspects) guard pred;
  schema = genAspects.mkAspectSchema cnf;
  baseLooms = {
    godet.aspects = [
      "hem"
      "tuck"
      "braid"
    ];
    jabot.aspects = [
      "hem"
      "tuck"
      "braid"
    ];
    ruffle.aspects = [
      "tuck"
      "braid"
    ];
  };
  valuesOf =
    extraAspects: looms:
    (genMerge.evalModuleTree { } [
      (schema.mkAspectModule { })
      {
        options.looms = genMerge.mkOption {
          type = genMerge.types.attrsOf genMerge.types.raw;
          default = { };
        };
      }
      {
        aspects = {
          braid.couching.stitches = [ "braid" ];
          tuck = guard (pred.has "bolt") {
            couching.stitches = [ "tuck" ];
            description = "tuck";
            includes = [ (t.readCtx "bolt" [ ]) ];
          };
          hem = guard (pred.has "weave") {
            couching.stitches = [ "hem" ];
            description = "hem";
          };
          pleat-godet.couching.stitches = [ "pleat-godet" ];
          pleat-jabot.couching.stitches = [ "pleat-jabot" ];
          pleat-ruffle.couching.stitches = [ "pleat-ruffle" ];
          # one sibling per tassel descendant
          fringe = guard (pred.has "tassel") {
            couching.stitches = [ "fringe" ];
            description = "fringe";
            includes = [ (t.readCtx "tassel" [ ]) ];
          };
          tassel-1.couching.stitches = [ "tassel-1" ];
          tassel-2.couching.stitches = [ "tassel-2" ];
        };
        inherit looms;
      }
      { aspects = extraAspects; }
    ]).config;
  values = valuesOf { } baseLooms;
  # A source is an identity, never the value it supplies.
  src = n: "entity:${builtins.hashString "sha256" n}";
  suppliers = {
    ${src "godet"}.bolt = "pleat-godet";
    ${src "jabot"}.bolt = "pleat-jabot";
    ${src "ruffle"}.bolt = "pleat-ruffle";
    ${src "batiste"}.weave = "batiste";
    ${src "organza"}.weave = "organza";
    ${src "t1"}.tassel = "tassel-1";
    ${src "t2"}.tassel = "tassel-2";
    ${src "flounce"}.bolt = "pleat-flounce";
  };
  pins = {
    godet = "batiste";
    jabot = "batiste";
    ruffle = "organza";
  };
  scopes = builtins.mapAttrs (n: pin: {
    members = values.looms.${n}.aspects;
    sources = {
      bolt = src n;
      weave = src pin;
    };
  }) pins;
  rel = genAspects.instancesFor cnf values.aspects {
    inherit suppliers;
    containment = { };
  } scopes;
  projectWith =
    v: instances:
    genDelivery.project {
      selectNodes = x: x.looms;
      deliveryClasses = couchingPinMap;
      inherit instances;
    } cnf v;
  realizeOf = p: genDelivery.realize { } couchingTerminals p;

  facts = genAspects.graphFacts cnf values.aspects;
  params = [
    "hem"
    "tuck"
  ];
  applied =
    n: p:
    (genAspects.instanceOf cnf { } {
      aspect = p;
      context = builtins.mapAttrs (k: s: suppliers.${s}.${k}) scopes.${n}.sources;
      sources = (scopes.${n}).sources;
    } (facts.nodeData.${p})).entry;
  coldValues =
    valuesOf
      (builtins.listToAttrs (
        builtins.concatMap (
          n:
          map (p: {
            name = "${p}-${n}";
            value = applied n p;
          }) (builtins.filter (p: builtins.elem p params) baseLooms.${n}.aspects)
        ) (builtins.attrNames pins)
      ))
      (
        builtins.mapAttrs (n: l: {
          aspects = map (p: if builtins.elem p params then "${p}-${n}" else p) l.aspects;
        }) baseLooms
      );
  cold = projectWith coldValues (
    genAspects.instancesFor cnf coldValues.aspects {
      inherit suppliers;
      containment = { };
    } { }
  );
  # An instance-key merge, the defect parity exists to catch: every loom reads godet's `tuck` vertex.
  merged = rel // {
    reaches = builtins.mapAttrs (_: r: r // { tuck = rel.reaches.godet.tuck; }) rel.reaches;
  };
in
{
  sharedEvalRel = rel;
  sharedEvalProjection = projectWith values rel;
  sharedEvalRealized = realizeOf (projectWith values rel);
  sharedEvalColdRealized = realizeOf cold;
  sharedEvalMergedRealized = realizeOf (projectWith values merged);
  # `flounce` reaches `fringe` under its own projection; its loom contains the tassels `named` maps,
  # each identifier to the tassel whose identity it carries, so the siblings come in identifier order.
  sharedEvalFanOut =
    named:
    let
      v = valuesOf { } { flounce.aspects = [ "fringe" ]; };
      rec0 = parent: key: x: {
        inherit parent key;
        identity = src x;
        marked = false;
        bindings = { };
      };
      r =
        genAspects.instancesFor cnf v.aspects
          {
            inherit suppliers;
            containment = {
              flounce = rec0 null "bolt" "flounce";
            }
            // builtins.mapAttrs (_: rec0 "flounce" "tassel") named;
          }
          {
            flounce = {
              members = [ "fringe" ];
              sources.bolt = src "flounce";
            };
          };
    in
    (realizeOf (
      genDelivery.project {
        selectNodes = x: x.looms;
        deliveryClasses = {
          flounce.couching = "couching-organza";
        };
        instances = r;
      } cnf v
    )).couching-organza.flounce.stitches;
}
