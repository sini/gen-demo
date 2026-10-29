# shellcheck shell=bash
# ── row 112 -- two `mkAspectModule` declarations of `options.aspects` over one cnf are one
#    construction, one module; over a genuinely differing cnf they are two, both declaring the
#    container with its `default`, and refused by name (nixpkgs' `bothHave`; den-hoag-a0gc,
#    den-hoag-xh14j K3; ADR-0008 one engine, ADR-0025 item 1) ──
# `mkAspectModule` is a keyed record: two of them over the SAME cnf are one construction, so the
# container is declared once and the evaluation serves (this row's unplanted control). Over a cnf that
# genuinely differs they are two constructions, both kept, and both declarations state the
# container's `default`, which is refused by name as nixpkgs refuses two declarations stating it, ahead
# of `aspectsRootWith`'s functor. The federated shape (the record applied to a module's own arguments
# beside the corpus's record) is the cell `aspect-container-declared-twice-stating-its-default-is-refused`.
# Both arms use `mkAspectModule` on both sides (never mixed with `mkAspectOption`): mixing the two
# construction methods trips an unrelated ADR-0033 stratum refusal and is not this construct.
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
check "T5 two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf unplanted (mkAspectModule declared twice over one cnf is one construction, one module)" \
  "$row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfok" 0 "" "$tmpdir/two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf-green.err" '["probe"]'
check "T5 two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf planted   (mkAspectModule declared twice over a genuinely differing cnf is refused by name, den-hoag-a0gc)" \
  "$row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfred" 1 \
  "gen-merge: The option \`aspects' in" \
  "$tmpdir/two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf-red.err"
check "T5 two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf catchable  (the refusal is caught by tryEval, not an abort)" \
  "$row_two_mkaspectmodule_declarations_of_options_aspects_merge_over_one_cnfcatch" 0 "" "$tmpdir/two-mkaspectmodule-declarations-of-options-aspects-merge-over-one-cnf-catch.err" 'CAUGHT'
