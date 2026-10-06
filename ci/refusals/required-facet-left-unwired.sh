# shellcheck shell=bash
# ── row 7 -- a required facet left unwired (mirrors C11's federated subgraph) ──
row_required_facet_left_unwired='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genLink = gen.lib.aspects.link;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  facetOpt = genMerge.mkOption { type = genMerge.types.raw; default = null; };
  selvageFacets = { selvageCap = { category = "facet"; contract = "capability"; option = facetOpt; };
                     selvageReq = { category = "facet"; contract = "capability"; option = facetOpt; }; };
  mkReg = modules: let schema = genAspects.mkAspectSchema { keySemantics = selvageFacets; }; in
    genMerge.evalModuleTree { } ([ { options.schema = schema.schemaOption; } (schema.mkAspectModule { }) ] ++ modules);
  mill = mkReg [ { config.aspects.stitch.selvageCap = { provides = [ "warp" "weft" ]; }; } ];
  loom = mkReg [ { config.aspects.braid = { selvageReq = { requires = [ "warp" ]; }; includes = [ (genAspects.keyRef "mill/stitch") ]; }; } ];
  mkFederated = wired: genLink.link {
    sources = [ { registry = mill.config.aspects; keySemantics = selvageFacets; origin = [ "mill" ]; }
                 { registry = loom.config.aspects; keySemantics = selvageFacets; origin = [ "loom" ]; } ];
    wire = if wired then { "loom/braid".selvageReq = "mill/stitch"; } else { }; };
in builtins.toJSON (mkFederated WIRED).resolved'
check "T5 required-facet-left-unwired unplanted (braid's capability requirement wired to the mill)" "${row_required_facet_left_unwired/WIRED/true}" 0 "" \
  "$tmpdir/required-facet-left-unwired-green.err" '{"loom/braid":["warp","weft"]}'
check "T5 required-facet-left-unwired planted   (braid's capability requirement left unwired)" "${row_required_facet_left_unwired/WIRED/false}" 1 \
  "gen-link.link: aspect 'loom/braid' has unwired required facet(s): selvageReq" \
  "$tmpdir/required-facet-left-unwired-red.err"
