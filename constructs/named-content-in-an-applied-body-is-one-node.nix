# ── named content in an applied body is one node (gen-aspects + gen-delivery;
# den-hoag-named-include-instance-bodies-sfkyy; identity design 2026-09-30 §2, ruling Q5 "yes"). A NAMED
# value in a parametric aspect's applied body is a sighting at the position of its `name` like a static
# one: the sightings are classed across the static tree and every instance of the relation, and a class
# the static tree already holds keeps its id. `binding` is included by the static `border` and in the
# applied bodies of `quilt` and `sash`: one node, so `coverlet`, reaching all three, receives it and its
# inner literal `binding-inl` once, and `pillow`, reaching only `quilt`, names the same id. `tape` is one
# factory whose `name` sits at one position: `tape "braid"` in `quilt`'s body and `tape "ribbon"` in
# `sash`'s are two classes, each delivering its own content.
{
  genAspects,
  genDelivery,
  genMerge,
}:
let
  inherit (genAspects) guard pred;
  cnf.keySemantics.couching.category = "class";
  t = genMerge.types;
  marked = n: { couching.stitches = [ n ]; };
  binding = {
    name = "binding";
    couching.stitches = [ "binding" ];
    includes = [ (marked "binding-inl") ];
  };
  tape = s: {
    name = "tape";
    couching.stitches = [ s ];
  };
  values =
    (genMerge.evalModuleTree { } [
      ((genAspects.mkAspectSchema cnf).mkAspectModule { })
      {
        options.hosts = genMerge.mkOption {
          type = t.attrsOf t.raw;
          default = { };
        };
      }
      {
        aspects = {
          border = marked "border" // {
            includes = [ binding ];
          };
          quilt = guard (pred.has "loom") (
            marked "quilt"
            // {
              includes = [
                binding
                (tape "braid")
              ];
            }
          );
          sash = guard (pred.has "loom") (
            marked "sash"
            // {
              includes = [
                binding
                (tape "ribbon")
              ];
            }
          );
        };
        hosts = {
          coverlet.aspects = [
            "border"
            "quilt"
            "sash"
          ];
          pillow.aspects = [ "quilt" ];
        };
      }
    ]).config;
  src = n: "entity:${builtins.hashString "sha256" n}";
  projection = genDelivery.project {
    selectNodes = _: values.hosts;
    instances =
      genAspects.instancesFor cnf values.aspects
        {
          suppliers = builtins.listToAttrs (
            map (h: {
              name = src h;
              value.loom = "loom-${h}";
            }) (builtins.attrNames values.hosts)
          );
          containment = { };
        }
        (
          builtins.mapAttrs (h: v: {
            members = v.aspects;
            sources.loom = src h;
          }) values.hosts
        );
  } cnf values;
  # a class key's content is a deferred module: its stitches are read through each `imports` layer
  stitchesIn =
    m:
    if builtins.isAttrs m then
      (m.stitches or [ ]) ++ builtins.concatMap stitchesIn (m.imports or [ ])
    else
      [ ];
in
{
  appliedNamedFacts = genAspects.graphFacts cnf values.aspects;
  appliedNamedIds = h: projection.nodes.${h}.elementIds.couching;
  appliedNamedStitches = builtins.mapAttrs (
    h: _: builtins.concatMap stitchesIn projection.nodes.${h}.classes.couching
  ) values.hosts;
}
