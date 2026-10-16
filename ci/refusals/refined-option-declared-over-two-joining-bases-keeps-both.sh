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
# second declaration, which forbids the defined `weft = 1`: the pair meets (den-hoag-rmxbx, G11) and
# the value is refused, so a library that dropped the refinement cannot pass. The pin is the refusal's
# CLASS, rc 1 and `is not of type `submodule'`, not its line (the file label is not pinned): nixpkgs'
# twin (`addCheck` over `submodule`) does not refuse this value at all, gen's refusal names the base type
# in nixpkgs' own form (den-hoag-k4f4g, gen-merge 4666f1e), and the refinement's own message is tracked
# as a separate quality row.
row_refined_option_declared_over_two_joining_bases_keeps_both='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  t = genMerge.types;
  woven = { check = _: true; message = "must be woven"; };
  felted = { check = v: (v.weft or 0) != 1; message = "must be felted"; };
  warp = t.submodule { options.warp = genMerge.mkOption { type = t.str; default = "tabby"; }; };
  weft = t.submodule { options.weft = genMerge.mkOption { type = t.int; default = 0; }; };
  bolt = b: r: genMerge.mkOption { type = WRAP; };
in builtins.concatStringsSep "," (builtins.attrNames (genMerge.evalModuleTree { } [
    { options.cloth = bolt FIRST woven; }
    { options.cloth = bolt SECOND SECONDREFINEMENT; }
    { cloth.weft = 1; }
  ]).config.cloth)'
row_refined_option_declared_over_two_joining_bases_keeps_bothbare="${row_refined_option_declared_over_two_joining_bases_keeps_both/WRAP/b}"
row_refined_option_declared_over_two_joining_bases_keeps_bothrefined="${row_refined_option_declared_over_two_joining_bases_keeps_both/WRAP/genSchema.refined b [ r ]}"
row_refined_option_declared_over_two_joining_bases_keeps_bothfwd="${row_refined_option_declared_over_two_joining_bases_keeps_bothrefined/FIRST/warp}"
row_refined_option_declared_over_two_joining_bases_keeps_bothfwd="${row_refined_option_declared_over_two_joining_bases_keeps_bothfwd/SECOND/weft}"
row_refined_option_declared_over_two_joining_bases_keeps_bothrev="${row_refined_option_declared_over_two_joining_bases_keeps_bothrefined/FIRST/weft}"
row_refined_option_declared_over_two_joining_bases_keeps_bothrev="${row_refined_option_declared_over_two_joining_bases_keeps_bothrev/SECOND/warp}"
row_refined_option_declared_over_two_joining_bases_keeps_bothctl="${row_refined_option_declared_over_two_joining_bases_keeps_bothbare/FIRST/warp}"
row_refined_option_declared_over_two_joining_bases_keeps_bothctl="${row_refined_option_declared_over_two_joining_bases_keeps_bothctl/SECOND/weft}"
check "T5 refined-option-declared-over-two-joining-bases-keeps-both control   (the BARE pair joins, and both option names are the assertion)" \
  "${row_refined_option_declared_over_two_joining_bases_keeps_bothctl/SECONDREFINEMENT/woven}" 0 "" \
  "$tmpdir/refined-option-declared-over-two-joining-bases-keeps-both-control.err" 'warp,weft'
check "T5 refined-option-declared-over-two-joining-bases-keeps-both unplanted (the same pair refined alike keeps both declarations)" \
  "${row_refined_option_declared_over_two_joining_bases_keeps_bothfwd/SECONDREFINEMENT/woven}" 0 "" \
  "$tmpdir/refined-option-declared-over-two-joining-bases-keeps-both-green.err" 'warp,weft'
check "T5 refined-option-declared-over-two-joining-bases-keeps-both unplanted (the other presentation order keeps both declarations)" \
  "${row_refined_option_declared_over_two_joining_bases_keeps_bothrev/SECONDREFINEMENT/woven}" 0 "" \
  "$tmpdir/refined-option-declared-over-two-joining-bases-keeps-both-green-rev.err" 'warp,weft'
check "T5 refined-option-declared-over-two-joining-bases-keeps-both planted   (a SECOND, different refinement on the same joining pair, forbidding the defined value)" \
  "${row_refined_option_declared_over_two_joining_bases_keeps_bothfwd/SECONDREFINEMENT/felted}" 1 \
  "is not of type \`submodule'" \
  "$tmpdir/refined-option-declared-over-two-joining-bases-keeps-both-red.err"
