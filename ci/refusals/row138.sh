# shellcheck shell=bash
# ── row 138 -- a merge strategy outside the declared three is refused by name at wrap's intake
#    (den-hoag-bvpuo; ADR-0025 item 1) ──
# gen-bind's `wrap` reads a merge strategy from caller data, and only "bind-wins", "system-wins" and
# "error" are declared. It used to act on any other value as bind-wins, silently: a misspelt
# `sytem-wins` served the binding where the caller asked for the module system's value. The door
# decodes `mergeStrategies` when `wrap opts` is formed, naming the field the caller wrote. The
# unplanted arm declares `system-wins` for a colliding `spool` and asserts the module system's
# value is served. Every arm is bound in the prelude, as row 116's are.
row138='let
  bind = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.bind;
  served = s: ((bind.wrap { bindings.spool = "linen"; mergeStrategies.spool = s; } ({ spool, config, ... }: { out = spool; })).module { config = { }; spool = "wool"; }).out;
  declared = builtins.toJSON (served "system-wins");
  misspelt = builtins.toJSON (served "sytem-wins");
  caught = if (builtins.tryEval (builtins.seq (served "sytem-wins") null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row138 unplanted (a declared system-wins serves the module-system value)" \
  "${row138/BODY/declared}" 0 "" "$tmpdir/row138-green.err" '"wool"'
check "T5 row138 planted   (a misspelt merge strategy is refused by name at the wrap intake)" \
  "${row138/BODY/misspelt}" 1 \
  'gen-bind.wrap: `mergeStrategies.spool` is "sytem-wins", not one of "bind-wins", "system-wins", "error"' \
  "$tmpdir/row138-red.err"
check "T5 row138 catchable  (the misspelt merge strategy is caught by tryEval, not an abort)" \
  "${row138/BODY/caught}" 0 "" "$tmpdir/row138-catch.err" 'CAUGHT'
