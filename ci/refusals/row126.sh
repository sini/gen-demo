# shellcheck shell=bash
# ── row 126 -- a check nixpkgs states over a gen union holding a nested tree, BY NAME (C110,
#    den-hoag-4ifgb M-A.3) ──
# A check `addCheck` states over gen-merge's `either tree str` is carried and evaluated: the tree's
# `check` is its module-value domain (den-hoag-f8mgj arm Q), so the union's check reads only the
# value. A failing check (`isAttrs` on a string) is refused by name, which a fold that dropped the
# check would serve; a passing one (`isString`) serves the value, which a fold that refused every
# such check would not. The unplanted arm is the same union without `addCheck` and serves the value,
# so a fold refusing every such union cannot pass.
row126='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  selvage = (genMerge.evalModuleTree {
    modules = [ { options.weave = genMerge.mkOption { type = genMerge.types.str; default = "plain"; }; } ];
  }).type;
in (genMerge.evalModuleTree {
  modules = [
    { options.spool = genMerge.mkOption { type = TYPE; }; }
    { spool = "sateen"; }
  ];
}).config.spool'
row126stated='genMerge.types.either selvage genMerge.types.str'
row126plant="lib.types.addCheck ($row126stated) builtins.isAttrs"
row126passing="lib.types.addCheck ($row126stated) builtins.isString"
row126unplanted="${row126/TYPE/$row126stated}"
row126planted="${row126/TYPE/$row126plant}"
row126served="${row126/TYPE/$row126passing}"
check "T5 row126 unplanted (the gen union holding a tree, no added check)" "$row126unplanted" 0 "" \
  "$tmpdir/row126-green.err" 'sateen'
check "T5 row126 passing   (a passing check added over a gen union holding a tree)" "$row126served" 0 "" \
  "$tmpdir/row126-passing.err" 'sateen'
check "T5 row126 planted   (a failing check added over a gen union holding a tree)" "$row126planted" 1 \
  "gen-merge: a definition for option \`spool' is not of type \`either'" \
  "$tmpdir/row126-red.err"
