# ── anonymous declarations are nodes (gen-aspects + gen-delivery; den-hoag-8hlo3; identity design
# 2026-09-30 §1, §2). Inline content written at an include position is a node of the aspect graph,
# keyed by where it was DECLARED (the declaring module, the option path, the structural path), and
# `project` delivers it as that node: `elementIds` names it beside what the host receives, and what
# the host receives does not move. `yoke` holds a literal that holds a nested literal and a NAMED
# element, which stays a position (a named value's site is not injective); one let-bound literal,
# `shared`, is included by `yoke` and by `cuff`, two declarations and two nodes; the parametric
# `gore` holds a literal in its applied body, one node per instance, reached by `bodice` and
# `sleeve`; `welt` includes an EDITED copy of `placard`'s literal, re-declared at `welt`'s own site,
# so `collar` receives the edit and `lapel` the original; and the two path modules
# `fixtures/anonymous-nodes/{front,back}.nix`, in both orders, give `seam` the same two ids.
{
  genAspects,
  genDelivery,
  genMerge,
}:
let
  cnf.keySemantics.couching.category = "class";
  inherit (genAspects) guard pred;
  t = genMerge.types;
  marked = n: { couching.stitches = [ n ]; };
  ev =
    mods:
    (genMerge.evalModuleTree { } (
      [
        ((genAspects.mkAspectSchema cnf).mkAspectModule { })
        {
          options.hosts = genMerge.mkOption {
            type = t.attrsOf t.raw;
            default = { };
          };
        }
      ]
      ++ mods
    )).config;
  shared = marked "shared";
  values = ev [
    {
      aspects = {
        yoke = marked "yoke" // {
          includes = [
            (
              marked "yoke-inl"
              // {
                includes = [
                  (marked "yoke-inn")
                  {
                    name = "piping";
                    couching.stitches = [ "piping" ];
                  }
                ];
              }
            )
            shared
          ];
        };
        cuff = marked "cuff" // {
          includes = [ shared ];
        };
        gore = guard (pred.has "loom") (
          marked "gore"
          // {
            includes = [ (marked "gore-inl") ];
          }
        );
        placard = marked "placard" // {
          includes = [ (marked "placard-inl") ];
        };
      };
      hosts = {
        bodice.aspects = [
          "yoke"
          "gore"
        ];
        sleeve.aspects = [
          "cuff"
          "gore"
        ];
        lapel.aspects = [ "placard" ];
      };
    }
    (
      { config, ... }:
      {
        aspects.welt = marked "welt" // {
          includes = [ ((builtins.head config.aspects.placard.includes) // marked "edited") ];
        };
        hosts.collar.aspects = [ "welt" ];
      }
    )
  ];
  src = n: "entity:${builtins.hashString "sha256" n}";
  rel = genAspects.instancesFor cnf values.aspects {
    suppliers = builtins.listToAttrs (
      map (h: {
        name = src h;
        value.loom = "loom-${h}";
      }) (builtins.attrNames values.hosts)
    );
    containment = { };
    scopes = builtins.mapAttrs (h: v: {
      members = v.aspects;
      sources.loom = src h;
    }) values.hosts;
  };
  projection = genDelivery.project {
    inherit values cnf;
    instances = rel;
    selectNodes = _: values.hosts;
  };
  # a class key's content is a deferred module: its stitches are read through each `imports` layer
  stitchesIn =
    m:
    if builtins.isAttrs m then
      (m.stitches or [ ]) ++ builtins.concatMap stitchesIn (m.imports or [ ])
    else
      [ ];
  front = ../fixtures/anonymous-nodes/front.nix;
  back = ../fixtures/anonymous-nodes/back.nix;
  seamIds =
    mods:
    builtins.filter (
      n: builtins.match "seam/includes/.*" n != null
    ) (genAspects.graphFacts cnf (ev mods).aspects).nodes;
in
{
  anonNodesFacts = genAspects.graphFacts cnf values.aspects;
  anonNodesRel = rel;
  anonNodesIds = h: projection.nodes.${h}.elementIds.couching;
  anonNodesStitches = builtins.mapAttrs (
    h: _: builtins.concatMap stitchesIn projection.nodes.${h}.classes.couching
  ) values.hosts;
  anonNodesSeam = {
    frontBack = seamIds [
      front
      back
    ];
    backFront = seamIds [
      back
      front
    ];
  };
}
