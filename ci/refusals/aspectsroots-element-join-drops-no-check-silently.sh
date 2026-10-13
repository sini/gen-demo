# shellcheck shell=bash
# ── row 74 -- aspectsRoot's element join drops no check silently: it goes through gen-merge's own
#    `mergeTypes`, so a join that drops `port`'s check is met with it and the value `port` rejects
#    is refused BY NAME, catchably (gen-aspects den-hoag-plm1h; den-hoag-rmxbx G11; ADR-0008 one
#    engine, ADR-0025 item 1) ──
# `aspectsRoot` used to join its element through the element's own foreign `typeMerge`, which joins
# nixpkgs `port` and `int` to bare `int`: `aspectsRoot(port) ∥ aspectsRoot(int)` merged and took
# 70000 for a port, and so did `aspectsRoot(port)` declared twice. The unplanted arm is the live
# control: the same element declared twice merges, and its value passes.
row_aspectsroots_element_join_drops_no_check_silently='let
  flake = builtins.getFlake (toString ./.);
  lib = flake.inputs.nixpkgs.lib;
  genAspects = flake.inputs.gen.lib.aspects.aspects;
  genMerge = flake.inputs.gen.lib.modules.merge;
  rootWith = (genAspects.aspectsRoot { keySemantics.a.category = "class"; }).functor.type;
  tree = genMerge.evalModuleTree { } [
      { options.p = genMerge.mkOption { type = rootWith lib.types.port; }; }
      { options.p = genMerge.mkOption { type = rootWith lib.types.SECOND; }; }
      { p.a = VALUE; }
    ];
in BODY'
row_aspectsroots_element_join_drops_no_check_silentlyok="${row_aspectsroots_element_join_drops_no_check_silently/SECOND/port}"
row_aspectsroots_element_join_drops_no_check_silentlyok="${row_aspectsroots_element_join_drops_no_check_silentlyok/VALUE/80}"
row_aspectsroots_element_join_drops_no_check_silentlyint="${row_aspectsroots_element_join_drops_no_check_silently/SECOND/int}"
row_aspectsroots_element_join_drops_no_check_silentlyint="${row_aspectsroots_element_join_drops_no_check_silentlyint/VALUE/70000}"
row_aspectsroots_element_join_drops_no_check_silentlyself="${row_aspectsroots_element_join_drops_no_check_silentlyok/p.a = 80/p.a = 70000}"
row_aspectsroots_element_join_drops_no_check_silentlyintok="${row_aspectsroots_element_join_drops_no_check_silentlyint/p.a = 70000/p.a = 80}"
check "T5 aspectsroots-element-join-drops-no-check-silently unplanted (aspectsRoot over one element, declared twice, merges and admits a port)" \
  "${row_aspectsroots_element_join_drops_no_check_silentlyok/BODY/builtins.toJSON [ tree.options.p.type.name tree.config.p ]}" 0 "" \
  "$tmpdir/aspectsroots-element-join-drops-no-check-silently-green.err" '["aspectsRoot",{"a":80}]'
check "T5 aspectsroots-element-join-drops-no-check-silently unplanted (aspectsRoot(port) and aspectsRoot(int) meet, and a port passes)" \
  "${row_aspectsroots_element_join_drops_no_check_silentlyintok/BODY/builtins.toJSON [ tree.options.p.type.name tree.config.p ]}" 0 "" \
  "$tmpdir/aspectsroots-element-join-drops-no-check-silently-green-int.err" '["aspectsRoot",{"a":80}]'
check "T5 aspectsroots-element-join-drops-no-check-silently planted   (aspectsRoot(port) and aspectsRoot(int) meet, and 70000 is refused by name)" \
  "${row_aspectsroots_element_join_drops_no_check_silentlyint/BODY/builtins.toJSON tree.config.p}" 1 \
  "gen-merge: a definition for option \`a' is not of type" \
  "$tmpdir/aspectsroots-element-join-drops-no-check-silently-red.err"
check "T5 aspectsroots-element-join-drops-no-check-silently planted   (aspectsRoot(port) declared twice keeps the port check)" \
  "${row_aspectsroots_element_join_drops_no_check_silentlyself/BODY/builtins.toJSON tree.config.p}" 1 \
  "gen-merge: a definition for option \`a' is not of type \`16 bit unsigned integer" \
  "$tmpdir/aspectsroots-element-join-drops-no-check-silently-red-self.err"
check "T5 aspectsroots-element-join-drops-no-check-silently catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_aspectsroots_element_join_drops_no_check_silentlyint/BODY/if (builtins.tryEval (builtins.deepSeq tree.config.p true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/aspectsroots-element-join-drops-no-check-silently-catch.err" 'CAUGHT'
