# `parametric-delivery` — C181, den-hoag-wpn8c (ADR-0010 §4(a); van Antwerpen 2018 §2.5). A node
# receives a reached parametric aspect's content through its instances: gen-aspects' `instancesFor`
# mints them, and gen-delivery's `project` reads the relation (`instances`) and never mints.
#
#   D1 entity-varying: `warp` and `weft` reach `selvage` through static `frame`. Each instance's
#      context-computed include names that node's loom (`jacquard` / `dobby`), and its nested `pick`
#      is delivered inside it. Each node receives its own and not the other's.
#   D2 the no-instance door: `bare` is handed no scope, so its reach of `selvage` is undecided and
#      refuses (a parametric aspect is never dropped).
#   D3 the instantiation edge is checked: a view whose `instantiates` points `warp`'s instance at
#      another declaration refuses, where reading the edge list alone would deliver it.
#   D4 a FALSE condition is no edge (den-hoag-n8wb5): `bobbin` reaches `nap`, which reads `shuttle`.
#      `plain` has no shuttle (a declared coordinate, so its absence is FALSE), the relation publishes
#      `nap` as declined there, and `plain` receives `bobbin` alone at rc 0; `twill`, whose loom
#      contains the shuttle `boat` (`containment`, den-hoag-8g2rn), receives `nap`.
#   D5 an undecided reach refuses: `loose` was handed a scope without `frame`, so the relation never
#      walked `selvage` there and neither lists nor declines it; the reach refuses rather than read as
#      declined, while `warp` delivers.
{
  asserts,
  genAlgebra,
  genAspects,
  genDelivery,
  genMerge,
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
          frame.nixos.marks = [ "frame" ];
          frame.includes = [ "selvage" ];
          bobbin.nixos.marks = [ "bobbin" ];
          bobbin.includes = [ "nap" ];
          selvage = guard (pred.has "loom") {
            nixos.marks = [ "selvage" ];
            description = "selvage";
            includes = [
              "pick"
              (t.readCtx "loom" [ ])
            ];
          };
          pick = guard (pred.has "loom") {
            nixos.marks = [ "pick" ];
            description = "pick";
          };
          nap = guard (pred.has "shuttle") { nixos.marks = [ "nap" ]; };
          jacquard.nixos.marks = [ "jacquard" ];
          dobby.nixos.marks = [ "dobby" ];
        };
      }
    ]).config.aspects;
  entity = n: inputs.gen.lib.substrate.identity.hashIdentity "entity" [ "name" ] (_: n);
  loomed = n: {
    members = [ "frame" ];
    sources.loom = entity n;
  };
  r = genAspects.instancesFor cnf aspects {
    suppliers = {
      ${entity "warp"}.loom = "jacquard";
      ${entity "weft"}.loom = "dobby";
      ${entity "twill"}.loom = "jacquard";
      ${entity "plain"}.loom = "jacquard";
      ${entity "boat"}.shuttle = "boat";
    };
    containment = {
      twill = {
        parent = null;
        key = "loom";
        identity = entity "twill";
        marked = false;
        bindings = { };
      };
      boat = {
        parent = "twill";
        key = "shuttle";
        identity = entity "boat";
        marked = false;
        bindings = { };
      };
    };
    scopes = {
      warp = loomed "warp";
      weft = loomed "weft";
      twill = loomed "twill" // {
        members = [ "bobbin" ];
      };
      plain = loomed "plain" // {
        members = [ "bobbin" ];
      };
      loose = loomed "warp" // {
        members = [ ];
      };
    };
  };
  projectWith =
    instances:
    genDelivery.project {
      values = {
        inherit aspects;
        hosts = {
          warp.aspects = [ "frame" ];
          weft.aspects = [ "frame" ];
          twill.aspects = [ "bobbin" ];
          plain.aspects = [ "bobbin" ];
          bare.aspects = [ "frame" ];
          loose.aspects = [ "frame" ];
        };
      };
      inherit cnf instances;
      selectNodes = v: v.hosts;
    };
  marksOf =
    p: n:
    (genMerge.evalModuleTree { } (
      [
        { freeformType = genMerge.types.lazyAttrsOf genMerge.types.anything; }
      ]
      ++ p.nodes.${n}.classes.nixos
    )).config.marks;
  refuses = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  p = projectWith r;
  sort = builtins.sort builtins.lessThan;
  d1 =
    sort (marksOf p "warp") == [
      "frame"
      "jacquard"
      "pick"
      "selvage"
    ]
    &&
      sort (marksOf p "weft") == [
        "dobby"
        "frame"
        "pick"
        "selvage"
      ];
  d2 = refuses (marksOf p "bare");
  warpI = builtins.head r.reaches.warp.selvage;
  d3 =
    refuses (
      marksOf (projectWith (
        r
        // {
          instantiates = r.instantiates // {
            ${warpI} = [ "pick" ];
          };
        }
      )) "warp"
    )
    && !(refuses (marksOf p "warp"));
  d4 =
    builtins.elem "nap" (marksOf p "twill")
    && marksOf p "plain" == [ "bobbin" ]
    && r.declined.reaches.plain == [ "nap" ];
  d5 = refuses (marksOf p "loose") && !(refuses (marksOf p "warp"));
in
{
  construct = [ "reached-parametric-aspect-is-delivered-through-its-instances" ];
  inherit
    d1
    d2
    d3
    d4
    d5
    ;
  check = asserts (d1 && d2 && d3 && d4 && d5);
}
