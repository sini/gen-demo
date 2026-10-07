# shellcheck shell=bash
# ── row 5 -- `gen.aspectCnf` absent (mirrors C6's extra `project` call) ──
row_gen_aspectcnf_absent='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genDelivery = gen.lib.framework.delivery;
  vals = { thimbles.pewter = { aspects = [ "stitch" ]; }; thimbles.damask = { aspects = [ ]; }; aspects.stitch.nixos = { foo = "bar"; }; };
  mkProj = withCnf: genDelivery.project { selectNodes = v: v.thimbles or { }; } (if withCnf then (import ./aspect-cnf.nix) else null) vals;
in builtins.toJSON (builtins.attrNames (mkProj WITHCNF).nodes)'
check "T5 gen-aspectcnf-absent unplanted (cnf present)" "${row_gen_aspectcnf_absent/WITHCNF/true}" 0 "" \
  "$tmpdir/gen-aspectcnf-absent-green.err" '["damask","pewter"]'
check "T5 gen-aspectcnf-absent planted   (cnf absent)" "${row_gen_aspectcnf_absent/WITHCNF/false}" 1 \
  "gen-delivery: project: no category source — \`cnf\` is required and has no default." \
  "$tmpdir/gen-aspectcnf-absent-red.err"
