# shellcheck shell=bash
# ── row 39 -- a non-string scope at `relationEntries` is refused by name (gen-view par76,
#    ADR-0025 item 1) ──
# `relationEntries` read `datumsAt.${scope}` with whatever it was handed, so an int scope aborted
# uncatchably (`expected a string but found an integer`). The arms differ by the scope alone; the
# unplanted arm asserts the datum filed there, so a library refusing every scope cannot pass it, and
# the catchable arm is the one that measures item 1 (row 33's form).
row39='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  admission = genView.labelWellFormedness { alphabet = labels; expression = "tacks*"; };
  order = genView.labelOrder { alphabet = labels; layers = [ [ "tacks" ] ]; endOfPath = -1; };
  graph = genView.scopeGraph {
    carrier = genView.carrier {
      inherit labels;
      relatumLabels = genView.relatumLabels { names = [ ]; };
      labelWellFormedness = admission; labelOrder = order;
      dataOrder = genView.dataOrder { channel = "selvage"; keyOf = c: c.scope; };
      relations = genView.relations { names = [ "gimp" ]; };
    };
    scopes = [ "grosgrain" "pewter" ];
    edges.tacks = id: { pewter = [ "grosgrain" ]; }.${id} or [ ];
    data = [ { scope = "grosgrain"; relation = "gimp"; datum = [ "cambric" ]; } ];
  };
  entries = genView.relationEntries { inherit graph; scope = SCOPE; relation = "gimp"; wellFormed = _: true; };
in BODY'
row39unplanted="${row39/SCOPE/\"grosgrain\"}"
row39planted="${row39/SCOPE/42}"
check "T5 row39 unplanted (a scope named by a string; its datum is the assertion)" \
  "${row39unplanted/BODY/builtins.toJSON (map (e: e.datum) entries)}" 0 "" \
  "$tmpdir/row39-green.err" '[["cambric"]]'
check "T5 row39 planted   (an int scope, refused by name)" \
  "${row39planted/BODY/builtins.deepSeq entries \"ADMITTED\"}" 1 \
  "gen-view.relationEntries: scope is 42; a scope is named by a string" \
  "$tmpdir/row39-red.err"
check "T5 row39 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row39planted/BODY/if (builtins.tryEval (builtins.deepSeq entries \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row39-catch.err" 'CAUGHT'
