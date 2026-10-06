# ── C11 — a packaged subgraph, federated (ADR-0011 §4, ADR-0027). gen-link ships no
# adapter/lens surface (measured, OPEN 2) — `link { sources; wire; }` with a per-origin
# `keySemantics` is what it ships, and that is what this declares.
{
  genAspects,
  genLink,
  genMerge,
}:
let
  selvageFacetOpt = genMerge.mkOption {
    type = genMerge.types.raw;
    default = null;
  };
  selvageFacets = {
    selvageCap = {
      category = "facet";
      contract = "capability";
      option = selvageFacetOpt;
    };
    selvageReq = {
      category = "facet";
      contract = "capability";
      option = selvageFacetOpt;
    };
  };
  mkSelvageRegistry =
    modules:
    let
      selvageSchema = genAspects.mkAspectSchema { keySemantics = selvageFacets; };
    in
    genMerge.evalModuleTree { } (
      [
        { options.schema = selvageSchema.schemaOption; }
        (selvageSchema.mkAspectModule { })
      ]
      ++ modules
    );
  mill = mkSelvageRegistry [
    {
      config.aspects.stitch.selvageCap = {
        provides = [
          "warp"
          "weft"
        ];
      };
    }
  ];
  loom = mkSelvageRegistry [
    {
      config.aspects.braid = {
        selvageReq = {
          requires = [ "warp" ];
        };
        includes = [ (genAspects.keyRef "mill/stitch") ];
      };
    }
  ];
  federated = genLink.link {
    sources = [
      {
        registry = mill.config.aspects;
        keySemantics = selvageFacets;
        origin = [ "mill" ];
      }
      {
        registry = loom.config.aspects;
        keySemantics = selvageFacets;
        origin = [ "loom" ];
      }
    ];
    wire."loom/braid".selvageReq = "mill/stitch";
  };
  selvageProvides = genLink.providesOf selvageFacets mill.config.aspects.stitch;

  # `frayed` is deliberately never added to `federated`'s `sources` below — the dangling entry
  # it carries would refuse the WHOLE `originStamp` call gen-link performs per source, so
  # folding it into the shared mill/loom federation would collaterally break every other C11
  # assertion that forces `federated` (den-hoag-lk06, mirroring the isolation gen-link's own
  # fixture keeps for the identical reason). It links alone, below.
  frayed = mkSelvageRegistry [
    {
      config.aspects.snag.includes = [ { } ];
    }
  ];

  # den-hoag-zxgan — the BARE-STRING counterpart to `frayed` above: a local includes entry naming a
  # key absent from the registry, spelled as a bare identifier rather than an anonymous `{ }`. A bare
  # string is unconditionally a REFERENCE (den-hoag-2zjg1), never inline content, so it is refused by
  # the SAME `rewrite.originStamp` lookup, catchably — no new refusal code, one shape substituted for
  # the other. Isolated for the identical reason `frayed` is: the dangling entry refuses the WHOLE
  # `originStamp` call, so folding it into `federated`'s shared sources would collaterally break
  # every other C11 assertion that forces `federated`.
  frayedBareString = mkSelvageRegistry [
    {
      config.aspects.orphanstr.includes = [ "no-such-sibling" ];
    }
  ];
in
{
  inherit
    selvageFacetOpt
    selvageFacets
    mkSelvageRegistry
    mill
    loom
    federated
    selvageProvides
    frayed
    frayedBareString
    ;
}
