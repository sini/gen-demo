# shellcheck shell=bash
# ── row 3 -- a Λ ∩ L collision in the carrier (mirrors C4's carrier, the label renamed at C3's
# own relata source, same seed the acceptance oracle uses to red C4 itself) ──
row3='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genView = gen.lib.substrate.view;
  mkCarrier = warpLabel:
    let
      bastingRelata = { ${warpLabel} = "pewter"; weft = "grosgrain"; };
      movementLabels = genView.edgeLabels { letters = [ "tacks" ]; };
    in genView.carrier {
      labels = movementLabels;
      relations = genView.relations { names = [ "gimp" ]; };
      relatumLabels = genView.relatumLabels { names = builtins.attrNames bastingRelata; };
      labelWellFormedness = genView.labelWellFormedness { alphabet = movementLabels; expression = "tacks*"; };
      labelOrder = genView.labelOrder { alphabet = movementLabels; layers = [ [ "tacks" ] ]; endOfPath = -1; };
      dataOrder = genView.dataOrder { channel = "selvage"; keyOf = _: "selvage"; };
    };
in builtins.toJSON (mkCarrier "LABEL").relatumLabels.names'
check "T5 row3 unplanted (relatum labelled warp)" "${row3/LABEL/warp}" 0 "" \
  "$tmpdir/row3-green.err" '["warp","weft"]'
check "T5 row3 planted   (relatum relabelled tacks, collides with L)" "${row3/LABEL/tacks}" 1 \
  "gen-view.carrier: 'tacks' is both a letter of L and a relatum label in Λ" \
  "$tmpdir/row3-red.err"
