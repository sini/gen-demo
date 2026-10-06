# shellcheck shell=bash
# ── row 19 -- A9, the discrete/monotone separation's message actionability (mirrors C19,
# den-hoag-0hwn): `checks.monotone-separation` asserts the refusal fires via `tryEval`, but
# `tryEval` exposes only `success`, never the thrown text, so whether the refusal NAMES the tag
# and the accessor -- rather than reading as an opaque abort -- is unreachable from that cell and
# is checked here instead ──
row_monotone_separation_refusal_names_its_accessor='let
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
check "T5 monotone-separation-refusal-names-its-accessor unplanted (children not declared in flight, sel.not still answers)" "${row_monotone_separation_refusal_names_its_accessor/INFLIGHT/[ ]}" 0 "" \
  "$tmpdir/monotone-separation-refusal-names-its-accessor-green.err" 'true'
check "T5 monotone-separation-refusal-names-its-accessor planted   (children declared in flight, sel.not refuses by name and by accessor)" \
  "${row_monotone_separation_refusal_names_its_accessor/INFLIGHT/[ \"children\" ]}" 1 \
  "sel.not observes the in-flight accessor \`children\` at a NON-MONOTONE position" \
  "$tmpdir/monotone-separation-refusal-names-its-accessor-red.err"
