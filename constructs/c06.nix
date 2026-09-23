# ── C6 — a delivery to one target (ADR-0028) ──
{
  config,
  genDelivery,
  genValues,
}:
let
  pewterClasses = builtins.attrNames config.gen.composed.nodes.pewter.classes;
  damaskClasses = builtins.attrNames config.gen.composed.nodes.damask.classes;
  stitchKeySet = builtins.attrNames config.gen.composed.aspects.stitch;

  # A SECOND ROUTE TO A PROJECTION, kept deliberately — and the cardinality is NO LONGER the
  # reason. `gen.nodeRegistryPath` names ONE attribute path because it names a delivery-target
  # VIEW and a view is singular (`den-hoag-uedvp`); the corpus declares the union of both
  # registries as `options.haberdashery` and names THAT path, so the hub now reaches every node
  # of both. What keeps this call is the reason the comment already gave second: it is the
  # corpus's only DIRECT exercise of `gen-delivery.project`'s `selectNodes` formal, which
  # survives the ruling and would be lost with the call. Calling `realize` directly is
  # rejected — it takes `terminals`, so the corpus would have to rebuild the hub's unexported
  # `terminalOf` bridge, and a corpus that reimplements the surface it tests has stopped
  # testing it. Taken instead: one extra check calling `project` directly with `selectNodes`,
  # so gen-delivery's own selector stays exercised beside the hub's option.
  bobbinProjection = genDelivery.project {
    values = genValues;
    cnf = import ../aspect-cnf.nix;
    selectNodes = v: v.bobbins or { };
  };
  bobbinProjectedNodes = builtins.attrNames bobbinProjection.nodes;
in
{
  inherit
    pewterClasses
    damaskClasses
    stitchKeySet
    bobbinProjection
    bobbinProjectedNodes
    ;
}
