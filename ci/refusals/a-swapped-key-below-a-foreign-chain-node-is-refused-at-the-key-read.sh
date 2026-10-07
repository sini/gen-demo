# shellcheck shell=bash
# ── a swapped key below a foreign chain node is refused at the key read (den-hoag-q6d1z; mirrors
#    `cells/foreign-chain-nested-keyed.nix`'s `swapped` chain; ADR-0025 item 1) ──
# On `uniq (lazyAttrsOf (attrsOf <gen attrsOf sub>))`, a stock-named `lazyAttrsOf` whose merge swaps
# two keys' trees is refused where an element below the read key is read, at THAT key: reading
# `o.foo` names `o.foo`, not `o.bar`, the key holding the moved tree. The cell's tryEval conjunct
# says that it refuses; this row says where. The unplanted arm is the same chain with the stock
# merge, and prints the value.
row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_read='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  np = flake.inputs.nixpkgs.lib.types;
  t = genMerge.types;
  sub = t.submodule { options.a = genMerge.mkOption { type = t.int; default = 0; }; };
  lazy = np.lazyAttrsOf (np.attrsOf (t.attrsOf sub));
  g = MERGE;
  chain = np.uniq (lazy // {
    merge = loc: defs: g (lazy.merge loc defs);
    substSubModules = m: let r = lazy.substSubModules m; in r // { merge = loc: defs: g (r.merge loc defs); };
  });
in toString (genMerge.evalModuleTree { } [
    { options.o = genMerge.mkOption { type = chain; }; }
    { o.foo.j.k.a = 1; o.bar.j.k.a = 2; }
  ]).config.o.foo.j.k.a'
row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_readswap='v: v // { foo = v.bar; bar = v.foo; }'
row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_readunplanted="${row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_read/MERGE/v: v}"
row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_readplanted="${row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_read/MERGE/$row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_readswap}"
check "T5 a-swapped-key-below-a-foreign-chain-node-is-refused-at-the-key-read unplanted (the stock merge serves the read key's own tree)" \
  "$row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_readunplanted" 0 "" \
  "$tmpdir/a-swapped-key-below-a-foreign-chain-node-is-refused-at-the-key-read-green.err" '1'
check "T5 a-swapped-key-below-a-foreign-chain-node-is-refused-at-the-key-read planted   (a merge swapping two keys' trees is refused at the key read)" \
  "$row_a_swapped_key_below_a_foreign_chain_node_is_refused_at_the_key_readplanted" 1 \
  "at option \`o.foo': the option type \`unique' states (its functors) that each key below it" \
  "$tmpdir/a-swapped-key-below-a-foreign-chain-node-is-refused-at-the-key-read-red.err"
