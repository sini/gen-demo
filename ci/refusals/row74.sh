# shellcheck shell=bash
# ── row 74 -- aspectsRoot's element join drops no check silently: it goes through gen-merge's own
#    `mergeTypes`, so a join the check-family witness refuses is refused BY NAME, catchably
#    (gen-aspects den-hoag-plm1h; ADR-0008 one engine, ADR-0025 item 1) ──
# `aspectsRoot` used to join its element through the element's own foreign `typeMerge`, which joins
# nixpkgs `port` and `int` to bare `int`: `aspectsRoot(port) ∥ aspectsRoot(int)` merged and took
# 70000 for a port, and so did `aspectsRoot(port)` declared twice. The unplanted arm is the live
# control: the same element declared twice merges, and its value passes.
row74='let
  flake = builtins.getFlake (toString ./.);
  lib = flake.inputs.nixpkgs.lib;
  genAspects = flake.inputs.gen.lib.aspects.aspects;
  genMerge = flake.inputs.gen.lib.modules.merge;
  rootWith = (genAspects.aspectsRoot { keySemantics.a.category = "class"; }).functor.type;
  tree = genMerge.evalModuleTree {
    modules = [
      { options.p = genMerge.mkOption { type = rootWith lib.types.port; }; }
      { options.p = genMerge.mkOption { type = rootWith lib.types.SECOND; }; }
      { p.a = VALUE; }
    ];
  };
in BODY'
row74ok="${row74/SECOND/port}"
row74ok="${row74ok/VALUE/80}"
row74int="${row74/SECOND/int}"
row74int="${row74int/VALUE/70000}"
row74self="${row74ok/p.a = 80/p.a = 70000}"
check "T5 row74 unplanted (aspectsRoot over one element, declared twice, merges and admits a port)" \
  "${row74ok/BODY/builtins.toJSON [ tree.options.p.type.name tree.config.p ]}" 0 "" \
  "$tmpdir/row74-green.err" '["aspectsRoot",{"a":80}]'
check "T5 row74 planted   (aspectsRoot(port) and aspectsRoot(int) do not merge, refused by name)" \
  "${row74int/BODY/builtins.toJSON tree.config.p}" 1 \
  "gen-merge: option \`p' is declared with types that do not merge (\`aspectsRoot' and \`aspectsRoot'" \
  "$tmpdir/row74-red.err"
check "T5 row74 planted   (aspectsRoot(port) declared twice keeps the port check)" \
  "${row74self/BODY/builtins.toJSON tree.config.p}" 1 \
  "gen-merge: a definition for option \`a' is not of type \`16 bit unsigned integer" \
  "$tmpdir/row74-red-self.err"
check "T5 row74 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row74int/BODY/if (builtins.tryEval (builtins.deepSeq tree.config.p true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row74-catch.err" 'CAUGHT'
