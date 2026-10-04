# `aspect-instance-identity` — C136, den-hoag-0cmbt (U6). A parametric aspect applied at a scope is a
# node of its own, the instance, identified by its declaration and the identities that supplied what it
# receives (gen-aspects `instanceOf`), and `instancesFor` is the relation of those nodes: one vertex
# per instance, edges from the scopes that reach it, and edges from a vertex to the instances its body
# reaches. The aspects are declared in the corpus's own grammar as first-order guards reading their
# coordinates (den-hoag-lwbb1 stage 2b: a context closure crosses the gen-rules door). Two entity kinds, `loom` (a scope's
# own) and `shuttle` (a descendant's), and one argument, `tension`, supplied by a gen-scope
# `argumentBinding` (K1): introduced at `loft` and inherited by `warpA` and `warpB`, overridden at
# `warpC`. Every context is derived from `suppliers`, written as one literal entry per supplier node.
#
# Each limb names the den-hoag-0cmbt spec §3a cell it carries:
#   I-1 `gauge` at two looms is two instances, and the relation's vertex id is `instanceOf`'s;
#   I-2 `warpA` and `warpB` differ in `dye`, which `gauge` never receives, and reach one instance;
#   I-4 `twill`, defined twice (a guard reading `loom` and one reading `tension`), is a guard carrier
#       whose formals are the union, `loom` and `tension` (the two bodies set distinct keys, `description`
#       and `note`: two firing definitions that disagree on one scalar are refused, C172);
#   R-3 `pick`, reached inside `gauge`'s body, is one nested instance, and `warpB`'s own `pick` edge
#       is that same vertex;
#   R-7 `heddle` fans out over a scope's shuttles, one instance each, and has no edge where there are
#       none;
#   B-2 the inherited binding is one id at both scopes that inherit it, and the override another, so
#       `temper` is one instance across `warpA` and `warpB` and another at `warpC`;
#   I-9 (den-hoag-ehkse) a guard declared at a path is identified by origin + declared path (identity
#       design §1), so `fringe`, `tassel`, `warpBeam.knot` and `clothBeam.knot`, one condition and one
#       non-class body apart from their `nixos` payloads, are four instances, each delivering its own
#       payload: siblings, one leaf name under two parents, and across a loom node and a shuttle node
#       that source `loom` from one entity. One declaration reached from two nodes at equal formals
#       stays one instance.
# `closed` (`guard pred.always`) reads nothing and is one instance everywhere. The context shapes
# `ctx:` and `{ ... }:`, and the shape classifier's S1 limb, retired with the context door: their
# narrowing moved to the gen-rules door.
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
    # the declared coordinates (design Q5): two entity kinds and two argument coordinates
    entityKinds = {
      loom = true;
      shuttle = true;
      tension = false;
      dye = false;
    };
  };
  t = (genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity).term;
  inherit (genAspects) guard pred;
  reads =
    coord: prefix: extra:
    guard (pred.has coord) (
      {
        description = t.concat [
          (t.lit prefix)
          (t.readCtx coord [ ])
        ];
      }
      // extra
    );
  aspects =
    (genMerge.evalModuleTree {
      modules = [
        { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
        {
          aspects = {
            frame.includes = [
              "closed"
              "gauge"
              "heddle"
              "twill"
              "temper"
            ];
            closed = guard pred.always { description = "closed"; };
            gauge = reads "loom" "gauge-" { includes = [ "pick" ]; };
            pick = reads "loom" "pick-" { };
            heddle = reads "shuttle" "heddle-" { };
            temper = reads "tension" "temper-" { };
          };
        }
        { aspects.twill = reads "loom" "twill:" { }; }
        {
          aspects.twill = guard (pred.has "tension") {
            note = t.concat [
              (t.lit "twill-")
              (t.readCtx "tension" [ ])
            ];
          };
        }
      ];
    }).config.aspects;

  entity = n: inputs.gen.lib.substrate.identity.hashIdentity "entity" [ "name" ] (_: n);
  binding =
    scope: name:
    genScope.argumentBinding {
      inherit scope name;
      supplyRoute = "specialArgs";
    };
  inherited = binding "loft" "tension";
  override = binding "warpC" "tension";
  dye = binding "warpB" "dye";

  # Written as a literal: one value per (supplier, key) by construction, and a repeated name aborts.
  suppliers = {
    ${entity "jacquard"}.loom = "jacquard";
    ${entity "dobby"}.loom = "dobby";
    ${entity "fly"}.shuttle = "fly";
    ${entity "boat"}.shuttle = "boat";
    ${entity "rapier"}.shuttle = "rapier";
    ${inherited}.tension = "taut";
    ${override}.tension = "slack";
    ${dye}.dye = "madder";
  };
  warp = loom: tension: shuttles: extra: members: {
    inherit members;
    sources = {
      loom = entity loom;
      inherit tension;
    }
    // extra;
    descendants = map (s: {
      sources = {
        loom = entity loom;
        shuttle = entity s;
        inherit tension;
      };
    }) shuttles;
  };
  r = genAspects.instancesFor cnf aspects {
    inherit suppliers;
    scopes = {
      warpA = warp "jacquard" inherited [ "fly" "boat" ] { } [ "frame" ];
      warpB = warp "jacquard" inherited [ "rapier" ] { inherit dye; } [
        "frame"
        "pick"
      ];
      warpC = warp "dobby" override [ ] { } [ "frame" ];
    };
  };
  at = n: a: r.reaches.${n}.${a} or [ ];
  descs = ids: builtins.sort (x: y: x < y) (map (id: r.vertices.${id}.entry.description) ids);
  one = a: at "warpA" a == at "warpB" a && builtins.length (at "warpA" a) == 1;
  apart = a: one a && at "warpC" a != at "warpA" a && builtins.length (at "warpC" a) == 1;

  wide = {
    loom = "jacquard";
    dye = "madder";
  };
  gaugeA = builtins.head (at "warpA" "gauge");
  i1 =
    apart "gauge"
    && descs (at "warpC" "gauge") == [ "gauge-dobby" ]
    &&
      (genAspects.instanceOf cnf {
        # the mint's relatum is the aspect's identity (`cnf.providerPrefix` is unset, so `[ ]`); a
        # vertex's `aspect` is its facts id
        aspect = genAspects.aspectId [ ] aspects.gauge;
        value = aspects.gauge;
        context = wide;
        sources = {
          loom = entity "jacquard";
          inherit dye;
        };
      }).id == gaugeA;
  i2 = one "gauge" && r.vertices.${gaugeA}.formals == { loom = entity "jacquard"; };
  shapes =
    one "closed"
    && at "warpC" "closed" == at "warpA" "closed"
    && r.vertices.${builtins.head (at "warpA" "closed")}.formals == { };
  twillA = r.vertices.${builtins.head (at "warpA" "twill")};
  i4 =
    aspects.twill ? fragments
    &&
      builtins.attrNames twillA.formals == [
        "loom"
        "tension"
      ]
    &&
      twillA.entry == (genAspects.mkGuardVocab cnf).applyGuard {
        loom = "jacquard";
        tension = "taut";
      } aspects.twill
    && apart "twill";
  nestedPick = builtins.concatMap (id: r.nested.${id}.pick or [ ]) (at "warpA" "gauge");
  r3 =
    builtins.length nestedPick == 1
    && descs nestedPick == [ "pick-jacquard" ]
    && at "warpB" "pick" == nestedPick
    && at "warpA" "pick" == [ ];
  r7 =
    descs (at "warpA" "heddle") == [
      "heddle-boat"
      "heddle-fly"
    ]
    && descs (at "warpB" "heddle") == [ "heddle-rapier" ]
    && !(r.reaches.warpC ? heddle);
  marked = m: guard (pred.has "loom") { nixos.marks = [ m ]; };
  # `knot` nests under two parents, so the closed body vocabulary lists it (C111)
  twinCnf = cnf // {
    freeformKeys = cnf.freeformKeys ++ [ "knot" ];
  };
  twins =
    (genMerge.evalModuleTree {
      modules = [
        { options.aspects = (genAspects.mkAspectSchema twinCnf).mkAspectOption { }; }
        {
          aspects = {
            fringe = marked "fringe";
            tassel = marked "tassel";
            warpBeam.knot = marked "warp-knot";
            clothBeam.knot = marked "cloth-knot";
          };
        }
      ];
    }).config.aspects;
  rt = genAspects.instancesFor twinCnf twins {
    inherit suppliers;
    scopes = {
      loomJ = {
        members = [
          "fringe"
          "tassel"
          "warpBeam/knot"
          "clothBeam/knot"
        ];
        sources.loom = entity "jacquard";
      };
      loomK = {
        members = [ "fringe" ];
        sources.loom = entity "jacquard";
      };
      shuttleF = {
        members = [ "tassel" ];
        sources = {
          loom = entity "jacquard";
          shuttle = entity "fly";
        };
      };
    };
  };
  marksAt = n: a: map (id: rt.vertices.${id}.entry.nixos.marks) rt.reaches.${n}.${a};
  i9 =
    builtins.length (builtins.attrNames rt.vertices) == 4
    && marksAt "loomJ" "fringe" == [ [ "fringe" ] ]
    && marksAt "loomJ" "tassel" == [ [ "tassel" ] ]
    && marksAt "loomJ" "warpBeam/knot" == [ [ "warp-knot" ] ]
    && marksAt "loomJ" "clothBeam/knot" == [ [ "cloth-knot" ] ]
    && rt.reaches.loomK.fringe != rt.reaches.shuttleF.tassel
    && marksAt "shuttleF" "tassel" == [ [ "tassel" ] ]
    && rt.reaches.loomK.fringe == rt.reaches.loomJ.fringe
    && rt.reaches.shuttleF.tassel == rt.reaches.loomJ.tassel;
  b2 =
    inherited != override
    && inherited == binding "loft" "tension"
    && apart "temper"
    && descs (at "warpA" "temper") == [ "temper-taut" ]
    && descs (at "warpC" "temper") == [ "temper-slack" ];
in
{
  construct = [ "C136" ];
  # B-2's bindings first: a constructor that ignores the scope makes `suppliers` name one binding
  # twice, which aborts uncatchably, so the conjunct that reads them apart must fail before it.
  check = asserts (b2 && i1 && i2 && shapes && i4 && r3 && r7 && i9);
}
