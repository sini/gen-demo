# shellcheck shell=bash
# ── row 120 -- declared content addressed to a class with no terminal is refused BY NAME at
#    gen-delivery's `realize` (C106; den-hoag-xtrxn; ADR-0025 item 1) ──
# A node's declared content for a class addresses that class's terminal, as an extra does, so a class
# with content and no terminal used to be dropped at exit 0 while an extra addressed there was
# refused. The planted arm realizes `crewel` only; the unplanted arm adds a `sashiko` terminal and
# asserts a STDOUT VALUE — the content arrived — so a `realize` that refused every call cannot pass it.
row120='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genDelivery = gen.lib.framework.delivery;
  projected.nodes.bobbinet = { bindings = { }; classes = { crewel = [ { stitch = "crewel"; } ]; sashiko = [ { stitch = "sashiko"; } ]; }; };
  realizeOver = terminals: genDelivery.realize { inherit projected terminals; };
  arrived = builtins.toJSON (realizeOver { crewel = a: a; sashiko = a: a; }).sashiko.bobbinet.modules;
  dropped = builtins.toJSON (builtins.attrNames (realizeOver { crewel = a: a; }).crewel);
in BODY'
check "T5 row120 unplanted (content with a terminal for its class arrives there)" \
  "${row120/BODY/arrived}" 0 "" "$tmpdir/row120-green.err" '[{"stitch":"sashiko"}]'
check "T5 row120 planted   (content for a class with no terminal is refused by name)" \
  "${row120/BODY/dropped}" 1 \
  "node bobbinet carries declared sashiko content, and class sashiko has no terminal" "$tmpdir/row120-red.err"
