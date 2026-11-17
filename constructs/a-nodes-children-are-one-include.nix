# ── a node's children are one include with one identity (gen-aspects `childBundle`). `loom` has three
# children: `warp` and `weft`, nested aspects, and `gate`, a guard leaf fired by a `rope` supplier.
# `p` and `q` each include `childBundle cnf config.aspects [ "loom" ]`, written inside the tree it
# enumerates: one bundle node, its members exactly loom's walk children. `frock` reaches the bundle at
# `p`, `smock` at `p` and `q` (each child once), and `plainHost` reaches `loom` itself, whose own
# content holds none of its children. The laziness pair adds `trap`, a child whose class content
# throws: a host that does not reach the bundle never reads it, and `frock`, which does, refuses.
{
  genAspects,
  genDelivery,
  genMerge,
}:
let
  cnf.keySemantics.couching.category = "class";
  t = genMerge.types;
  marked = n: { couching.stitches = [ n ]; };
  src = h: "entity:${builtins.hashString "sha256" h}";
  valuesWith =
    loomExtra:
    (genMerge.evalModuleTree { } [
      ((genAspects.mkAspectSchema cnf).mkAspectModule { })
      {
        options.hosts = genMerge.mkOption {
          type = t.attrsOf t.raw;
          default = { };
        };
      }
      (
        { config, ... }:
        let
          loomChildren = genAspects.childBundle cnf config.aspects [ "loom" ];
        in
        {
          aspects = {
            loom =
              marked "loom"
              // {
                warp = marked "warp";
                weft = marked "weft";
                gate = genAspects.guard (genAspects.pred.has "rope") (marked "gate");
              }
              // loomExtra;
            p.includes = [ loomChildren ];
            q.includes = [ loomChildren ];
            plain.includes = [ "loom" ];
          };
          hosts = {
            frock.aspects = [ "p" ];
            smock.aspects = [
              "p"
              "q"
            ];
            plainHost.aspects = [ "plain" ];
          };
        }
      )
    ]).config;
  stitchesOf =
    values:
    let
      projection = genDelivery.project {
        selectNodes = _: values.hosts;
        instances =
          genAspects.instancesFor cnf values.aspects
            {
              suppliers = builtins.listToAttrs (
                map (h: {
                  name = src h;
                  value.rope = "rope-${h}";
                }) (builtins.attrNames values.hosts)
              );
              containment = { };
            }
            (
              builtins.mapAttrs (h: v: {
                members = v.aspects;
                sources.rope = src h;
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
    builtins.mapAttrs (
      h: _: builtins.concatMap stitchesIn projection.nodes.${h}.classes.couching
    ) values.hosts;
  values = valuesWith { };
  lazyStitches = stitchesOf (valuesWith {
    trap.couching.stitches = throw "a child's content the host does not reach";
  });
  try =
    v:
    let
      r = builtins.tryEval (builtins.deepSeq v v);
    in
    if r.success then r.value else "REFUSED";
in
{
  childBundleFacts = genAspects.graphFacts cnf values.aspects;
  childBundleStitches = stitchesOf values;
  childBundleLazy = {
    plainHost = try lazyStitches.plainHost;
    frock = try lazyStitches.frock;
  };
}
