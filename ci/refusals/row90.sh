# shellcheck shell=bash
# ── row 90 -- a non-node coordinate under gen-product's DEFAULT codec is refused BY NAME, catchably,
#    at `cell` (den-hoag-i25f; ADR-0025 item 1) ──
# A factor spec that gives neither `key` nor `entryOf` takes gen-product's defaults: `key` reads
# `id_hash`, `entryOf` is the graph's `nodeData`. Over gen-graph's `fromRegistry` that lookup is
# total (`{ }` on an unknown id), so a non-node used to abort inside the default `key`
# (`attribute 'id_hash' missing`, which `tryEval` cannot contain) instead of reaching gen-product's
# not-a-node refusal. The unplanted arm addresses a registry entry through the same product and
# asserts a STDOUT VALUE, so a `cell` that refused everything cannot pass it. Both addressings are
# bound in the prelude: a `}` inside a `${row90/BODY/...}` replacement would end the expansion early.
row90='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProduct = gen.lib.substrate.product;
  genGraph = gen.lib.substrate.graph;
  reg = { sharp = { id_hash = "sharp"; name = "sharp"; }; };
  needle = { dim = "needle"; graph = genGraph.fromRegistry { registry = reg; edges = _: _: [ ]; }; };
  space = genProduct.productN "cartesian" [ needle ];
  sharp = genProduct.cell space { needle = reg.sharp; };
  blunt = genProduct.cell space { needle = { id_hash = "blunt"; name = "blunt"; }; };
in BODY'
check "T5 row90 unplanted (a registry entry addresses under the default codec)" \
  "${row90/BODY/sharp}" 0 "" "$tmpdir/row90-green.err" '["sharp"]'
check "T5 row90 planted   (a non-node under the default codec is refused by name)" \
  "${row90/BODY/blunt}" 1 \
  "gen-product: not-a-node in dim 'needle' — blunt" "$tmpdir/row90-red.err"
check "T5 row90 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row90/BODY/if (builtins.tryEval (builtins.deepSeq blunt null)).success then \"ADMITTED\" else \"CAUGHT\"}" \
  0 "" "$tmpdir/row90-catch.err" 'CAUGHT'
