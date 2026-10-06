# shellcheck shell=bash
# ── row 1 -- a binding relatum minted in the SAME pass (mirrors C3's mintStrata) ──
row_binding_relatum_minted_in_the_same_pass='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  emitters = pass1: [
    { pass = 0; identifier = "pewter"; kind = "thimble"; relata = { }; content = { spool = "linen"; }; site = "c:pewter"; }
    { pass = 0; identifier = "grosgrain"; kind = "bobbin"; relata = { }; content = { gauge = "fine"; }; site = "c:gros"; }
    { pass = pass1; identifier = "basting:pewter:grosgrain"; kind = "basting"; content = { tension = "slack"; }; relata = { warp = "pewter"; weft = "grosgrain"; }; site = "c:basting"; }
  ];
in builtins.toJSON (builtins.attrNames (genScope.mintStrata { } (emitters PASS)).nodes)'
check "T5 binding-relatum-minted-in-the-same-pass unplanted (basting minted strictly later)" "${row_binding_relatum_minted_in_the_same_pass/PASS/1}" 0 "" \
  "$tmpdir/binding-relatum-minted-in-the-same-pass-green.err" '["basting:pewter:grosgrain","grosgrain","pewter"]'
check "T5 binding-relatum-minted-in-the-same-pass planted   (basting minted in the same pass)" "${row_binding_relatum_minted_in_the_same_pass/PASS/0}" 1 \
  "gen-scope.mintStrata: unresolved relatum 'pewter' (label 'warp', minting kind 'basting', pass 0)" \
  "$tmpdir/binding-relatum-minted-in-the-same-pass-red.err"
