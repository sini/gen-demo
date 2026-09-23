# shellcheck shell=bash
# ── row 9 -- a retired lattice key declared on a cyclic member (mirrors C15's cyclic stratum) ──
row9='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  lib = (builtins.getFlake (toString ./.)).inputs.nixpkgs.lib;
  genMemo = gen.lib.substrate.memo;
  genScope = gen.lib.substrate.scope;
  cyclicAccessor = { dependencies = id: { chintz = [ "tulle" ]; tulle = [ "chintz" "organdy" ]; }.${id} or [ ]; nodeData = id: { inherit id; }; };
  reach = acc: view: id: lib.sort (a: b: a < b) (lib.unique ([ id ] ++ lib.concatLists (map (d: view.${d} or [ ]) (acc.dependencies id))));
  reachLattice = { bottom = [ ]; join = a: b: lib.sort (x: y: x < y) (lib.unique (a ++ b)); maxIter = 8; };
  mkSolved = eqKey: genMemo.runScc genScope.ascend {
    accessor = cyclicAccessor; recompute = reach; store = { };
    scc = [ "chintz" "tulle" ]; higherStrata = { organdy = [ "organdy" ]; };
    lattices = { chintz = if eqKey then reachLattice // { eq = a: b: a == b; } else reachLattice; tulle = reachLattice; };
  };
in builtins.toJSON (mkSolved EQKEY).chintz'
check "T5 row9 unplanted (both lattices declare only bottom/join/maxIter)" "${row9/EQKEY/false}" 0 "" \
  "$tmpdir/row9-green.err" '["chintz","organdy","tulle"]'
check "T5 row9 planted   (chintz's lattice still declares the retired eq key)" "${row9/EQKEY/true}" 1 \
  "gen-memo: cyclic member declares retired lattice key" \
  "$tmpdir/row9-red.err"
