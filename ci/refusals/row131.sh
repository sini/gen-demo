# shellcheck shell=bash
# ── row 131 -- a node the delivery-class map does not readdress keeps its authored class, and with no
#    terminal for that class it is refused BY NAME at gen-delivery's `realize` (C118; den-hoag-htfv3) ──
# C118's cell holds that the realization refuses; tryEval cannot read which refusal it caught, so the
# node and the class are read here. The planted arm omits `ruffle`'s entry; the unplanted arm carries
# it and asserts a STDOUT VALUE -- ruffle realized under `couching-organza` -- so a `project` or
# `realize` that refused every map cannot pass it.
row131='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genDelivery = gen.lib.framework.delivery;
  merge = gen.lib.modules.merge;
  cnf.keySemantics.couching.category = "class";
  values = (merge.evalModuleTree {
    modules = [
      ((genAspects.mkAspectSchema cnf).mkAspectModule { })
      { aspects.braid.couching.stitches = [ "braid" ]; }
    ];
  }).config;
  realizeWith = deliveryClasses: genDelivery.realize {
    projected = genDelivery.project {
      inherit values cnf deliveryClasses;
      selectNodes = _: { godet.aspects = [ "braid" ]; ruffle.aspects = [ "braid" ]; };
    };
    terminals = { couching-batiste = c: c.name; couching-organza = c: c.name; };
  };
  arrived = builtins.toJSON (realizeWith { godet.couching = "couching-batiste"; ruffle.couching = "couching-organza"; }).couching-organza;
  dropped = builtins.toJSON (realizeWith { godet.couching = "couching-batiste"; });
in BODY'
check "T5 row131 unplanted (a readdressed node realizes under its delivery class)" \
  "${row131/BODY/arrived}" 0 "" "$tmpdir/row131-green.err" '{"ruffle":"ruffle"}'
check "T5 row131 planted   (a node left under an authored class with no terminal is refused by name)" \
  "${row131/BODY/dropped}" 1 \
  "node ruffle carries declared couching content, and class couching has no terminal" "$tmpdir/row131-red.err"
