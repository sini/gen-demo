# shellcheck shell=bash
# ── row 14 -- a node declared in BOTH registries, colliding in the delivery target view
# (mirrors the corpus's `options.haberdashery`, `den-hoag-uedvp`) ──
#
# `gen.nodeRegistryPath` names ONE attribute path because it names a delivery-target VIEW, so a
# consumer with several registries declares their union as its own option. THE COLLISION RULE IS
# THE MODULE SYSTEM'S, not one gen writes, and this row is what pins that: `attrsOf raw` fed by
# `mkMerge` refuses a node declared in both, BY NAME. The rejected `//` is the reason the row
# exists -- it is right-wins, so the same corpus spelled with `//` drops `pewter` from the
# delivery set at exit 0 with zero diagnostics. Nothing in gen can refuse that spelling, so the
# `mkMerge` arm's refusal is the only thing holding the ruled construction in place.
row14='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  reg = genMerge.mkOption { type = genMerge.types.attrsOf genMerge.types.raw; default = { }; };
  mod = { config, ... }: {
    options = { thimbles = reg; bobbins = reg; haberdashery = reg; };
    config = {
      thimbles.pewter = { spool = "linen"; };
      bobbins.BOBBIN = { gauge = "fine"; };
      haberdashery = genMerge.mkMerge [ config.thimbles config.bobbins ];
    };
  };
in builtins.toJSON (builtins.attrNames (gen.lib.compose { modules = [ mod ]; }).values.haberdashery.pewter)'
check "T5 row14 unplanted (bobbins.grosgrain, no node in both registries)" "${row14/BOBBIN/grosgrain}" 0 "" \
  "$tmpdir/row14-green.err" '["spool"]'
check "T5 row14 planted   (bobbins.pewter, the same node in both registries)" "${row14/BOBBIN/pewter}" 1 \
  "gen-merge: the option \`haberdashery.pewter' has conflicting definitions" \
  "$tmpdir/row14-red.err"
