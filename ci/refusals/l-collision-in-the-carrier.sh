# shellcheck shell=bash
# ── row 3 -- a Λ ∩ L collision in the carrier (mirrors C4's carrier, the label renamed at C3's
# own relata source, same seed the acceptance oracle uses to red C4 itself) ──
row_l_collision_in_the_carrier='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genView = gen.lib.substrate.view;
  genScope = gen.lib.substrate.scope;
  mkCarrier = warpLabel:
    let
      bastingRelata = { ${warpLabel} = "pewter"; weft = "grosgrain"; };
      movementLabels = genView.edgeLabels { letters = [ "tacks" ]; };
    in genView.carrier {
      labels = movementLabels;
      relations = genView.relations { names = [ "gimp" ]; };
      relatumLabels = genView.relatumLabels { names = builtins.attrNames bastingRelata; };
      labelWellFormedness = genScope.wellFormed { alphabet = movementLabels.letters; expression = "tacks*"; };
      labelOrder = genScope.labelOrder { alphabet = movementLabels.letters; layers = [ [ "tacks" ] ]; endOfPath = -1; };
      dataOrder = genView.dataOrder { channel = "selvage"; keyOf = _: "selvage"; };
    };
in builtins.toJSON (mkCarrier "LABEL").relatumLabels.names'
check "T5 l-collision-in-the-carrier unplanted (relatum labelled warp)" "${row_l_collision_in_the_carrier/LABEL/warp}" 0 "" \
  "$tmpdir/l-collision-in-the-carrier-green.err" '["warp","weft"]'
check "T5 l-collision-in-the-carrier planted   (relatum relabelled tacks, collides with L)" "${row_l_collision_in_the_carrier/LABEL/tacks}" 1 \
  "gen-view.carrier: 'tacks' is both a letter of L and a relatum label in Λ" \
  "$tmpdir/l-collision-in-the-carrier-red.err"
