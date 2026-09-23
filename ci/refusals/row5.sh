# shellcheck shell=bash
# ── row 5 -- `gen.aspectCnf` absent (mirrors C6's extra `project` call) ──
row5='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genDelivery = gen.lib.framework.delivery;
  vals = { thimbles.pewter = { aspects = [ "stitch" ]; }; thimbles.damask = { aspects = [ ]; }; aspects.stitch.nixos = { foo = "bar"; }; };
  mkProj = withCnf: genDelivery.project {
    values = vals;
    cnf = if withCnf then (import ./aspect-cnf.nix) else null;
    selectNodes = v: v.thimbles or { };
  };
in builtins.toJSON (builtins.attrNames (mkProj WITHCNF).nodes)'
check "T5 row5 unplanted (cnf present)" "${row5/WITHCNF/true}" 0 "" \
  "$tmpdir/row5-green.err" '["damask","pewter"]'
check "T5 row5 planted   (cnf absent)" "${row5/WITHCNF/false}" 1 \
  "gen-delivery: project: no category source — \`cnf\` is required and has no default." \
  "$tmpdir/row5-red.err"
