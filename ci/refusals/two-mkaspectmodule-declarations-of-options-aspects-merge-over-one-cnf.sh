# shellcheck shell=bash
# ── row 112 -- two `mkAspectModule` declarations of `options.aspects` merge over one cnf, mirroring
#    `gen-modules/aspects-redeclaration.nix`'s own construction; over a genuinely differing cnf they
#    are refused by name (gen-aspects `aspectsRoot`'s functor, den-hoag-a0gc; ADR-0008 one engine,
#    ADR-0025 item 1) ──
# `aspects-redeclaration.nix` declares `options.aspects` a second time, through a second
# `mkAspectModule` over the SAME cnf as `corpus.nix`'s, and the two merge — that is the corpus's own
# green arm, and this row's unplanted control reproduces it standalone. The refusal arm a0gc's own
# report left owed: the identical construction over a cnf that genuinely differs is refused BY NAME,
# because `aspectsRootWith`'s functor (this bead's own fix) decides the two elements do not reconcile
# rather than merging on the container's name alone. Both arms use `mkAspectModule` on both sides
# (never mixed with `mkAspectOption`): mixing the two construction methods trips an unrelated
# ADR-0033 stratum refusal and is not this construct — the reason `aspects-redeclaration.nix` itself
# states for using `mkAspectModule` twice.
row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnf='let
  flake = builtins.getFlake (toString ./.);
  genAspects = flake.inputs.gen.lib.aspects.aspects;
  genMerge = flake.inputs.gen.lib.modules.merge;
  cnf1 = import ./aspect-cnf.nix;
  cnf2 = cnf1 // { keySemantics = cnf1.keySemantics // { grommet.category = "class"; }; };
  s1 = genAspects.mkAspectSchema cnf1;
  s2 = genAspects.mkAspectSchema SECOND;
  tree = genMerge.evalModuleTree { } [
      (s1.mkAspectModule { })
      (s2.mkAspectModule { })
      { aspects.probe = { }; }
    ];
in BODY'
row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfok="${row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnf/SECOND/cnf1}"
row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfok="${row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfok/BODY/builtins.toJSON (builtins.attrNames tree.config.aspects)}"
row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfred="${row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnf/SECOND/cnf2}"
row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfred="${row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfred/BODY/builtins.toJSON (builtins.attrNames tree.config.aspects)}"
row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfcatch="${row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnf/SECOND/cnf2}"
row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfcatch="${row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfcatch/BODY/if (builtins.tryEval (builtins.deepSeq (builtins.attrNames tree.config.aspects) true)).success then \"ADMITTED\" else \"CAUGHT\"}"
check "T5 two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf unplanted (mkAspectModule declared twice over one cnf still merges, mirroring aspects-redeclaration.nix)" \
  "$row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfok" 0 "" "$tmpdir/two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf-green.err" '["probe"]'
check "T5 two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf planted   (mkAspectModule declared twice over a genuinely differing cnf is refused by name, den-hoag-a0gc)" \
  "$row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfred" 1 \
  "gen-merge: option \`aspects' is declared with types that do not merge (\`aspectsRoot' and \`aspectsRoot'" \
  "$tmpdir/two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf-red.err"
check "T5 two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf catchable  (the refusal is caught by tryEval, not an abort)" \
  "$row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfcatch" 0 "" "$tmpdir/two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf-catch.err" 'CAUGHT'
