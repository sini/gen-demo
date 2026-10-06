# shellcheck shell=bash
# ── row 138 -- a merge strategy outside the declared three is refused by name at wrap's intake
#    (den-hoag-bvpuo; ADR-0025 item 1) ──
# gen-bind's `wrap` reads a merge strategy from caller data, and only "bind-wins", "system-wins" and
# "error" are declared. It used to act on any other value as bind-wins, silently: a misspelt
# `sytem-wins` served the binding where the caller asked for the module system's value. The door
# decodes `mergeStrategies` when `wrap opts` is formed, naming the field the caller wrote. The
# unplanted arm declares `system-wins` for a colliding `spool` and asserts the module system's
# value is served. Every arm is bound in the prelude, as row 116's are.
row_merge_strategy_outside_the_declared_three='let
  bind = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.bind;
  served = s: ((bind.wrap { bindings.spool = "linen"; mergeStrategies.spool = s; } ({ spool, config, ... }: { out = spool; })).module { config = { }; spool = "wool"; }).out;
  declared = builtins.toJSON (served "system-wins");
  misspelt = builtins.toJSON (served "sytem-wins");
  caught = if (builtins.tryEval (builtins.seq (served "sytem-wins") null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 merge-strategy-outside-the-declared-three unplanted (a declared system-wins serves the module-system value)" \
  "${row_merge_strategy_outside_the_declared_three/BODY/declared}" 0 "" "$tmpdir/merge-strategy-outside-the-declared-three-green.err" '"wool"'
check "T5 merge-strategy-outside-the-declared-three planted   (a misspelt merge strategy is refused by name at the wrap intake)" \
  "${row_merge_strategy_outside_the_declared_three/BODY/misspelt}" 1 \
  'gen-bind.wrap: `mergeStrategies.spool` is "sytem-wins", not one of "bind-wins", "system-wins", "error"' \
  "$tmpdir/merge-strategy-outside-the-declared-three-red.err"
check "T5 merge-strategy-outside-the-declared-three catchable  (the misspelt merge strategy is caught by tryEval, not an abort)" \
  "${row_merge_strategy_outside_the_declared_three/BODY/caught}" 0 "" "$tmpdir/merge-strategy-outside-the-declared-three-catch.err" 'CAUGHT'
