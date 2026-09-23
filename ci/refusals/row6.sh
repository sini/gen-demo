# shellcheck shell=bash
# ── row 6 -- an edge/decls id not a declared member (mirrors C8's contribution protocol) ──
row6='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  genAssemble = gen.lib.framework.assemble;
  thimbles = { name = "thimbles"; vertices = [ "pewter" "damask" ];
    decls = { pewter = { spool = "linen"; aspects = [ "stitch" ]; }; damask = { spool = "sateen"; aspects = [ ]; }; }; };
  mkBobbins = bobbinVertices: { name = "bobbins"; vertices = bobbinVertices;
    edgeGraphs = [ { label = "tacks"; graph = genScope.edge "pewter" "grosgrain"; } ];
    decls = { grosgrain = { gauge = "fine"; }; faille = { gauge = "coarse"; }; }; };
in builtins.toJSON (builtins.attrNames (genAssemble.assemble { contributions = [ thimbles (mkBobbins BOBBINVERTICES) ]; }).nodes)'
check "T5 row6 unplanted (grosgrain declared a member)" "${row6/BOBBINVERTICES/[ \"grosgrain\" \"faille\" ]}" 0 "" \
  "$tmpdir/row6-green.err" '["damask","faille","grosgrain","pewter"]'
check "T5 row6 planted   (grosgrain named by an edge and a decls entry, never a declared member)" \
  "${row6/BOBBINVERTICES/[ \"faille\" ]}" 1 \
  "gen-assemble: the contribution \`bobbins\` carries an edge under the label \`tacks\` whose \`to\` endpoint \`grosgrain\` is not a declared member" \
  "$tmpdir/row6-red.err"
