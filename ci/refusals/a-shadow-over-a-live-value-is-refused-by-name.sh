# shellcheck shell=bash
# ── a shadow over a live value is refused by name in the published `types` link (den-hoag-y9vzt) ──
# gen-merge's `types` is gen-types' vocabulary linked under gen-merge's own strategies, and the link
# keeps no record of what it shadows, so it admits a shadow only over a tombstone: at `attrs`, the
# shipped gen-types keeps a refused-by-name tombstone and gen-merge's fold answers. The planted arm
# hands the same library a vocabulary serving a LIVE checker there (gen-types' own `checkedAttrs`),
# and the allowlisted name is refused by name rather than shadowed silently. The unplanted arm reads
# a fold through the shipped namespace, so a link refusing every shadow cannot pass; the catchable
# arm holds that the refusal is a throw.
row_a_shadow_over_a_live_value='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  gt = gen.lib.modules.types;
  over = types: import "${gen.inputs.gen-merge}/lib" {
    inherit types;
    inherit (gen.lib.substrate) prelude memo scope;
  };
  read = genMerge: (genMerge.evalModuleTree { } [
      { options.selvedge = genMerge.mkOption { type = genMerge.types.attrs; }; }
      { selvedge.warp = "flax"; }
      { selvedge.weft = "tussah"; }
    ]).config.selvedge;
  green = builtins.toJSON (read (over gt));
  planted = builtins.toJSON (read (over (gt // { attrs = gt.checkedAttrs; })));
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-shadow-over-a-live-value-is-refused-by-name unplanted (the shipped vocabulary keeps a tombstone at attrs; the fold answers)" \
  "${row_a_shadow_over_a_live_value/BODY/green}" 0 "" "$tmpdir/a-shadow-over-a-live-value-green.err" '{"warp":"flax","weft":"tussah"}'
check "T5 a-shadow-over-a-live-value-is-refused-by-name planted   (a live checker at attrs is refused by name, not shadowed)" \
  "${row_a_shadow_over_a_live_value/BODY/planted}" 1 \
  "linkset: 'gen-merge' shadows a live value of 'the supplied \`types\` vocabulary' at name 'attrs'." \
  "$tmpdir/a-shadow-over-a-live-value-red.err"
check "T5 a-shadow-over-a-live-value-is-refused-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_shadow_over_a_live_value/BODY/caught}" 0 "" "$tmpdir/a-shadow-over-a-live-value-catch.err" 'CAUGHT'
