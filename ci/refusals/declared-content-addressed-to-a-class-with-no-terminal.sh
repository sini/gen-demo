# shellcheck shell=bash
# ── row 125 -- declared content addressed to a class with no terminal is refused BY NAME at
#    gen-delivery's `realize` (C109; den-hoag-xtrxn; ADR-0025 item 1) ──
# A node's declared content for a class addresses that class's terminal, as an extra does, so a class
# with content and no terminal used to be dropped at exit 0 while an extra addressed there was
# refused. The planted arm realizes `crewel` only and reads `sashiko` with a fallback, the shape a
# consumer's output mapping uses; the unplanted arm adds a `sashiko` terminal and asserts a STDOUT
# VALUE — the content arrived — so a `realize` that refused every call cannot pass it.
row_declared_content_addressed_to_a_class_with_no_terminal='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genDelivery = gen.lib.framework.delivery;
  projected.nodes.bobbinet = { bindings = { }; classes = { crewel = [ { stitch = "crewel"; } ]; sashiko = [ { stitch = "sashiko"; } ]; }; };
  realizeOver = terminals: genDelivery.realize { } terminals projected;
  arrived = builtins.toJSON (realizeOver { crewel = a: a; sashiko = a: a; }).sashiko.bobbinet.modules;
  dropped = builtins.toJSON ((realizeOver { crewel = a: a; }).sashiko or "absent");
in BODY'
check "T5 declared-content-addressed-to-a-class-with-no-terminal unplanted (content with a terminal for its class arrives there)" \
  "${row_declared_content_addressed_to_a_class_with_no_terminal/BODY/arrived}" 0 "" "$tmpdir/declared-content-addressed-to-a-class-with-no-terminal-green.err" '[{"stitch":"sashiko"}]'
check "T5 declared-content-addressed-to-a-class-with-no-terminal planted   (content for a class with no terminal is refused by name)" \
  "${row_declared_content_addressed_to_a_class_with_no_terminal/BODY/dropped}" 1 \
  "node bobbinet carries declared sashiko content, and class sashiko has no terminal" "$tmpdir/declared-content-addressed-to-a-class-with-no-terminal-red.err"
