# shellcheck shell=bash
# ── row 94 -- a class crossing addressed where the class does not realize is refused BY NAME at
#    gen-delivery's `realize` (C74; den-hoag-9vkq; ADR-0028's Rider) ──
# `realize`'s extras are addressed `{ <class>.<node> = [ module ]; }` and supplement a realization
# without creating one, so an address at a node with no declared content for the class used to be
# dropped at exit 0. The planted arm addresses `smocking.ruche` (ruche carries quilting only); the
# unplanted arm addresses `smocking.picot` and asserts a STDOUT VALUE — the crossing arrived — so a
# `realize` that refused every address cannot pass it. Both addressings are bound in the prelude: a
# `}` inside a `${row94/BODY/...}` replacement would end the expansion early.
row94='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genDelivery = gen.lib.framework.delivery;
  projected.nodes = {
    picot = { bindings = { }; classes = { smocking = [ { stitch = "smocking"; } ]; quilting = [ { stitch = "quilting"; } ]; }; };
    ruche = { bindings = { }; classes.quilting = [ { stitch = "quilting"; } ]; };
  };
  terminals = { smocking = a: a; quilting = a: a; };
  crossTo = node: genDelivery.realize { inherit projected terminals; extraModules.smocking.${node} = [ { adaptedFrom.stitch = "quilting"; } ]; };
  arrived = builtins.toJSON (crossTo "picot").smocking.picot.extraModules;
  dropped = builtins.toJSON (builtins.attrNames (crossTo "ruche").smocking);
in BODY'
check "T5 row94 unplanted (a crossing addressed where smocking realizes arrives there)" \
  "${row94/BODY/arrived}" 0 "" "$tmpdir/row94-green.err" '[{"adaptedFrom":{"stitch":"quilting"}}]'
check "T5 row94 planted   (a crossing addressed where smocking does not realize is refused by name)" \
  "${row94/BODY/dropped}" 1 \
  "extraModules.smocking.ruche addresses a node with no declared smocking content" "$tmpdir/row94-red.err"
