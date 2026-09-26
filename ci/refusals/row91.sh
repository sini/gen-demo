# shellcheck shell=bash
# ── row 91 -- a non-node coordinate is refused BY NAME, catchably, at gen-product's `fiber` and `slice`
#    (den-hoag-qfcs3; ADR-0025 item 1) ──
# `fiber` and `slice` checked that the DIMENSION was free but never that the fixed COORDINATE was a
# node, so a stale or mistyped coordinate read as a clean empty fiber (`[ ]` at exit 0). They now pass
# it through the same pointwise not-a-node door as `cell`. The unplanted arm fibers on a registry
# entry and asserts a STDOUT VALUE, so a `fiber` that refused everything cannot pass it; the slice arm
# fixes a real node and a non-node, and the refusal names the non-node's dim. Every addressing is
# bound in the prelude: a `}` inside a `${row91/BODY/...}` replacement would end the expansion early.
row91='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProduct = gen.lib.substrate.product;
  genGraph = gen.lib.substrate.graph;
  factor = dim: registry: { inherit dim; graph = genGraph.fromRegistry { inherit registry; edges = _: _: [ ]; }; };
  needles = { sharp = { id_hash = "sharp"; name = "sharp"; }; };
  threads = { eye = { id_hash = "eye"; name = "eye"; }; };
  blunt = { id_hash = "blunt"; name = "blunt"; };
  space = genProduct.productN "cartesian" [ (factor "needle" needles) (factor "thread" threads) ];
  sharpFiber = builtins.concatStringsSep "," (genProduct.fiber space "needle" needles.sharp).nodes;
  bluntFiber = builtins.concatStringsSep "," (genProduct.fiber space "needle" blunt).nodes;
  bluntSlice = builtins.concatStringsSep "," (genProduct.slice space { needle = needles.sharp; thread = blunt; }).nodes;
  caught = if (builtins.tryEval (builtins.deepSeq bluntFiber null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row91 unplanted (a registry entry fibers to its cells)" \
  "${row91/BODY/sharpFiber}" 0 "" "$tmpdir/row91-green.err" '["eye"]'
check "T5 row91 planted   (a non-node fiber coordinate is refused by name)" \
  "${row91/BODY/bluntFiber}" 1 \
  "gen-product: not-a-node in dim 'needle' — blunt" "$tmpdir/row91-red.err"
check "T5 row91 slice     (a non-node slice coordinate is refused, naming its dim)" \
  "${row91/BODY/bluntSlice}" 1 \
  "gen-product: not-a-node in dim 'thread' — blunt" "$tmpdir/row91-slice.err"
check "T5 row91 catchable  (the refusal is caught by tryEval, not an empty fiber)" \
  "${row91/BODY/caught}" 0 "" "$tmpdir/row91-catch.err" 'CAUGHT'
