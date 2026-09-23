# shellcheck shell=bash
# ── row 19 -- A9, the discrete/monotone separation's message actionability (mirrors C19,
# den-hoag-0hwn): `checks.monotone-separation` asserts the refusal fires via `tryEval`, but
# `tryEval` exposes only `success`, never the thrown text, so whether the refusal NAMES the tag
# and the accessor -- rather than reading as an opaque abort -- is unreachable from that cell and
# is checked here instead ──
row19='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSelect = gen.lib.substrate.select;
  ctx = genSelect.adapters.registry.mkContext {
    nodes = [ "a" "b" ];
    data = _: { };
    parent = _: null;
    entryFor = _: null;
    inFlight = INFLIGHT;
  };
in builtins.toJSON (genSelect.matches (genSelect.not (genSelect.has (genSelect.attrs { key = "b"; }))) "a" ctx)'
check "T5 row19 unplanted (children not declared in flight, sel.not still answers)" "${row19/INFLIGHT/[ ]}" 0 "" \
  "$tmpdir/row19-green.err" 'true'
check "T5 row19 planted   (children declared in flight, sel.not refuses by name and by accessor)" \
  "${row19/INFLIGHT/[ \"children\" ]}" 1 \
  "sel.not observes the in-flight accessor \`children\` at a NON-MONOTONE position" \
  "$tmpdir/row19-red.err"
