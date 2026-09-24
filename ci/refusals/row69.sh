# shellcheck shell=bash
# ── row 69 -- a refined option declared over two JOINING bases keeps both (gen-schema cgbc5) ──
# `refined`'s merge relation asked gen-merge whether its base merged with the partner's and then kept
# its OWN base, throwing the join away. Two refined `submodule` declarations of one option lost the
# earlier one's options: silently in one order (the value simply lacked them), as an unrelated
# "option does not exist" in the other. gen-merge README `### typeMergeRel` clause (a) names that
# "the type-level form of a dropped definition"; the relation now refines the base relation's join.
# ★ NOT A REFUSAL ROW. The unplanted arms assert a stdout VALUE, both option names, so a library that
# refused every redeclaration cannot pass them -- row 30's reason. The bare pair is the live control:
# it is what the refined pair must answer. The planted arm differs by one refinement record on the
# second declaration, and must refuse, so a library that merged every refined pair cannot pass it.
row69='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  t = genMerge.types;
  woven = { check = _: true; message = "must be woven"; };
  felted = { check = _: true; message = "must be felted"; };
  warp = t.submodule { options.warp = genMerge.mkOption { type = t.str; default = "tabby"; }; };
  weft = t.submodule { options.weft = genMerge.mkOption { type = t.int; default = 0; }; };
  bolt = b: r: genMerge.mkOption { type = WRAP; };
in builtins.concatStringsSep "," (builtins.attrNames (genMerge.evalModuleTree {
  modules = [
    { options.cloth = bolt FIRST woven; }
    { options.cloth = bolt SECOND SECONDREFINEMENT; }
    { cloth.weft = 1; }
  ];
}).config.cloth)'
row69bare="${row69/WRAP/b}"
row69refined="${row69/WRAP/genSchema.refined b [ r ]}"
row69fwd="${row69refined/FIRST/warp}"
row69fwd="${row69fwd/SECOND/weft}"
row69rev="${row69refined/FIRST/weft}"
row69rev="${row69rev/SECOND/warp}"
row69ctl="${row69bare/FIRST/warp}"
row69ctl="${row69ctl/SECOND/weft}"
check "T5 row69 control   (the BARE pair joins, and both option names are the assertion)" \
  "${row69ctl/SECONDREFINEMENT/woven}" 0 "" \
  "$tmpdir/row69-control.err" 'warp,weft'
check "T5 row69 unplanted (the same pair refined alike keeps both declarations)" \
  "${row69fwd/SECONDREFINEMENT/woven}" 0 "" \
  "$tmpdir/row69-green.err" 'warp,weft'
check "T5 row69 unplanted (the other presentation order keeps both declarations)" \
  "${row69rev/SECONDREFINEMENT/woven}" 0 "" \
  "$tmpdir/row69-green-rev.err" 'warp,weft'
check "T5 row69 planted   (a SECOND, different refinement on the same joining pair)" \
  "${row69fwd/SECONDREFINEMENT/felted}" 1 \
  "does not reconcile" \
  "$tmpdir/row69-red.err"
