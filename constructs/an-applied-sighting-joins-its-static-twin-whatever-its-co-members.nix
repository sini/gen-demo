# ── an applied sighting joins its static twin whatever its co-members are (gen-aspects + gen-delivery;
# den-hoag-c4ucc arm (D), owner 2026-11-05; ADR-0034's constructor-less carve-out). One factory `cord`
# makes `{ v = 2^53 + 1; }`, which gen-identity's mint takes, and `{ v = 2^53 as a float; }`, which it
# refuses (ADR-0016 r4's excluded float domain); the two are `==`. The static `twine` includes both, so
# they are one static class. `hitch`'s applied body fires the int: it joins `twine`'s class through the
# int member's digest, whatever the float member is. `bend`'s applied body fires the float: content the
# mint refuses joins no static class (P2-b), so it is keyed within its own instance.
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
  cord = v: {
    name = "cord";
    couching.stitches = [ "cord" ];
    inherit v;
  };
  int = 9007199254740993;
  float = 9007199254740992.0;
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
          twine = marked "twine" // {
            includes = [
              (cord int)
              (cord float)
            ];
          };
          hitch = guard (pred.has "rope") (marked "hitch" // { includes = [ (cord int) ]; });
          bend = guard (pred.has "rope") (marked "bend" // { includes = [ (cord float) ]; });
        };
        hosts = {
          mooring.aspects = [
            "twine"
            "hitch"
          ];
          davit.aspects = [ "bend" ];
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
in
{
  twinFacts = genAspects.graphFacts cnf values.aspects;
  twinIds = h: projection.nodes.${h}.elementIds.couching;
}
