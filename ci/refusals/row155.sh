# shellcheck shell=bash
# ── row 155 -- an edge label no letter can walk is refused at the lift, BY NAME
#    (gen-scope f3f5532, den-hoag-25dd7; premise P14) ──
# `$` marks the end of a path and `_` is the any-label wildcard, so no alphabet may list either as a
# letter. The lift used to carry an edge labelled `$` under `decls.__edges`, where no resolution
# walks it; it now refuses the label naming why. The unplanted arm lifts the same edge as `peer` and
# reads it back by the one-letter resolution, so a lift that refused every label cannot pass it.
row155='let
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  liftAs = label: genScope.buildRoots {
    parentGraph = genScope.vertices [ "loom" "heddle" ];
    edgeGraphs = [ { inherit label; graph = genScope.edge { from = "loom"; to = "heddle"; }; } ];
  };
  roots = liftAs LABEL;
  ev = genScope.eval { } {
    children = _: _: { };
    marks = _: _: [ ];
    imports = _: _: [ ];
    edges-peer = _: id: roots.nodes.${id}.decls.__edges.peer;
  } roots;
in BODY'
row155ok="${row155/LABEL/\"peer\"}"
row155bad="${row155/LABEL/\"\$\"}"
row155read='builtins.toJSON (genScope.followEdge "peer" ev "loom")'
row155lift='builtins.toJSON roots.nodes.loom.decls.__edges'
row155catch='if (builtins.tryEval (builtins.deepSeq roots.nodes true)).success then "ADMITTED" else "CAUGHT"'
check "T5 row155 unplanted (an ordinary label is carried and walked by its one letter)" \
  "${row155ok/BODY/$row155read}" 0 "" "$tmpdir/row155-green.err" '["heddle"]'
check "T5 row155 planted   (the end-of-path label is refused at the lift, naming why no letter walks it)" \
  "${row155bad/BODY/$row155lift}" 1 \
  "gen-scope.buildRoots: \`edgeGraphs\` carries reserved label(s) [\"\$\"]: '\$' is the extended label marking the end of a path, which no alphabet may list as a letter" \
  "$tmpdir/row155-red.err"
check "T5 row155 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row155bad/BODY/$row155catch}" 0 "" "$tmpdir/row155-catch.err" 'CAUGHT'
