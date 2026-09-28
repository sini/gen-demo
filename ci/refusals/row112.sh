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
row112='let
  flake = builtins.getFlake (toString ./.);
  genAspects = flake.inputs.gen.lib.aspects.aspects;
  genMerge = flake.inputs.gen.lib.modules.merge;
  cnf1 = import ./aspect-cnf.nix;
  cnf2 = cnf1 // { keySemantics = cnf1.keySemantics // { grommet.category = "class"; }; };
  s1 = genAspects.mkAspectSchema cnf1;
  s2 = genAspects.mkAspectSchema SECOND;
  tree = genMerge.evalModuleTree {
    modules = [
      (s1.mkAspectModule { })
      (s2.mkAspectModule { })
      { aspects.probe = { }; }
    ];
  };
in BODY'
row112ok="${row112/SECOND/cnf1}"
row112ok="${row112ok/BODY/builtins.toJSON (builtins.attrNames tree.config.aspects)}"
row112red="${row112/SECOND/cnf2}"
row112red="${row112red/BODY/builtins.toJSON (builtins.attrNames tree.config.aspects)}"
row112catch="${row112/SECOND/cnf2}"
row112catch="${row112catch/BODY/if (builtins.tryEval (builtins.deepSeq (builtins.attrNames tree.config.aspects) true)).success then \"ADMITTED\" else \"CAUGHT\"}"
check "T5 row112 unplanted (mkAspectModule declared twice over one cnf still merges, mirroring aspects-redeclaration.nix)" \
  "$row112ok" 0 "" "$tmpdir/row112-green.err" '["probe"]'
check "T5 row112 planted   (mkAspectModule declared twice over a genuinely differing cnf is refused by name, den-hoag-a0gc)" \
  "$row112red" 1 \
  "gen-merge: option \`aspects' is declared with types that do not merge (\`aspectsRoot' and \`aspectsRoot'" \
  "$tmpdir/row112-red.err"
check "T5 row112 catchable  (the refusal is caught by tryEval, not an abort)" \
  "$row112catch" 0 "" "$tmpdir/row112-catch.err" 'CAUGHT'
