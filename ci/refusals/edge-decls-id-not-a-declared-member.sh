# shellcheck shell=bash
# ── row 6 -- an edge/decls id not a declared member (mirrors C8's contribution protocol) ──
row_edge_decls_id_not_a_declared_member='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  genAssemble = gen.lib.framework.assemble;
  thimbles = { name = "thimbles"; vertices = [ "pewter" "damask" ];
    decls = { pewter = { spool = "linen"; aspects = [ "stitch" ]; }; damask = { spool = "sateen"; aspects = [ ]; }; }; };
  mkBobbins = bobbinVertices: { name = "bobbins"; vertices = bobbinVertices;
    edgeGraphs = [ { label = "tacks"; graph = genScope.edge {
      from = "pewter";
      to = "grosgrain";
    }; } ];
    decls = { grosgrain = { gauge = "fine"; }; faille = { gauge = "coarse"; }; }; };
in builtins.toJSON (builtins.attrNames (genAssemble.assemble { } [ thimbles (mkBobbins BOBBINVERTICES) ]).nodes)'
check "T5 edge-decls-id-not-a-declared-member unplanted (grosgrain declared a member)" "${row_edge_decls_id_not_a_declared_member/BOBBINVERTICES/[ \"grosgrain\" \"faille\" ]}" 0 "" \
  "$tmpdir/edge-decls-id-not-a-declared-member-green.err" '["damask","faille","grosgrain","pewter"]'
check "T5 edge-decls-id-not-a-declared-member planted   (grosgrain named by an edge and a decls entry, never a declared member)" \
  "${row_edge_decls_id_not_a_declared_member/BOBBINVERTICES/[ \"faille\" ]}" 1 \
  "gen-assemble: the contribution \`bobbins\` carries an edge under the label \`tacks\` whose \`to\` endpoint \`grosgrain\` is not a declared member" \
  "$tmpdir/edge-decls-id-not-a-declared-member-red.err"
