# ── named inline content is one node (gen-aspects; den-hoag-qxip5; identity design 2026-09-30 §2,
# ruling Q5 "yes"). A NAMED value written at include positions is keyed by the position of its `name`
# and the name; the sightings at that key are one node per class of authored values the rung decides
# equal. `bias` is included by `hem` and by `facing`, one node: `frock`, which reaches both, receives
# its content once, and `smock`, which reaches only `facing`, receives it too. `tape` is one factory
# whose `name` sits at one position: `tape "satin"` at `hem` and `tape "twill"` at `facing` are two
# classes, each delivering its own content. `bias` holds a literal, `bias-inl`, one node under the
# class whichever host reaches it.
{
  genAspects,
  genDelivery,
  genMerge,
}:
let
  cnf.keySemantics.couching.category = "class";
  t = genMerge.types;
  marked = n: { couching.stitches = [ n ]; };
  bias = {
    name = "bias";
    couching.stitches = [ "bias" ];
    includes = [ (marked "bias-inl") ];
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
          hem = marked "hem" // {
            includes = [
              bias
              (tape "satin")
            ];
          };
          facing = marked "facing" // {
            includes = [
              bias
              (tape "twill")
            ];
          };
        };
        hosts = {
          frock.aspects = [
            "hem"
            "facing"
          ];
          smock.aspects = [ "facing" ];
        };
      }
    ]).config;
  # No parametric aspect here, so the instance relation is the empty one.
  projection = genDelivery.project {
    selectNodes = _: values.hosts;
    instances =
      genAspects.instancesFor cnf values.aspects
        {
          suppliers = { };
          containment = { };
        }
        (
          builtins.mapAttrs (_: v: {
            members = v.aspects;
            sources = { };
          }) values.hosts
        );
  } cnf values;
  stitchesIn =
    m:
    if builtins.isAttrs m then
      (m.stitches or [ ]) ++ builtins.concatMap stitchesIn (m.imports or [ ])
    else
      [ ];
in
{
  namedNodesFacts = genAspects.graphFacts cnf values.aspects;
  namedNodesIds = h: projection.nodes.${h}.elementIds.couching;
  namedNodesStitches = builtins.mapAttrs (
    h: _: builtins.concatMap stitchesIn projection.nodes.${h}.classes.couching
  ) values.hosts;
}
