# shellcheck shell=bash
# ── row 46 -- a non-string relation kind is refused at the mint (gen-identity 12ntx) ──
# `hashIdentity` handed a non-string kind to `builtins.match`, whose type failure escapes tryEval, so
# a lambda kind aborted the evaluation. The mint now refuses a non-string kind (and label) by name.
# The two arms differ by the KIND only; the unplanted arm asserts the identity, so a mint refusing
# every kind cannot pass it.
row46='let
  inherit ((builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.identity) hashIdentity;
in hashIdentity KIND [ "spool" ] (_: "linen")'
row46unplanted="${row46/KIND/\"thimble\"}"
row46planted="${row46/KIND/(x: x)}"
check "T5 row46 unplanted (a string kind mints, and the identity is the assertion)" \
  "$row46unplanted" 0 "" "$tmpdir/row46-green.err" 'thimble:13ccbea8f37b673e832c95463487e7cfb76ccf16a6117271258e3f53dd425cb4'
check "T5 row46 planted   (a lambda kind, refused by name at the mint)" \
  "builtins.deepSeq ($row46planted) \"ADMITTED\"" 1 \
  "identity: a lambda as the relation kind; a kind is a string" \
  "$tmpdir/row46-red.err"
check "T5 row46 catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval ($row46planted)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/row46-catch.err" 'CAUGHT'
