# shellcheck shell=bash
# ── a value-reading merge below a foreign chain node is refused where it reads (den-hoag-lif3n;
#    mirrors `cells/foreign-chain-nested-keyed.nix`'s `valueSwapped` chain; ADR-0025 item 1) ──
# On `uniq (lazyAttrsOf (attrsOf <gen attrsOf sub>))`, a stock-named `lazyAttrsOf` whose merge swaps
# `foo` and `bar` unless `baz`'s value is 3 places as the definitions' sites lead it (a site record
# has no value, so it swaps) and as the values lead it (it does not). Reading `o.foo` reaches `baz`,
# read while deciding placement where the fold over the sites holds another element at the key
# read, so the read is refused by name at `o.baz.j`, the element it read, never served the swapped
# tree. The cell's tryEval conjunct says that it refuses; this row says where and why. The
# unplanted arm is the same chain swapping unconditionally, which serves nixpkgs' value.
row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_reads='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  np = flake.inputs.nixpkgs.lib.types;
  t = genMerge.types;
  sub = t.submodule { options.a = genMerge.mkOption { type = t.int; default = 0; }; };
  lazy = np.lazyAttrsOf (np.attrsOf (t.attrsOf sub));
  swap = v: v // { foo = v.bar; bar = v.foo; };
  g = MERGE;
  chain = np.uniq (lazy // {
    merge = loc: defs: g (lazy.merge loc defs);
    substSubModules = m: let r = lazy.substSubModules m; in r // { merge = loc: defs: g (r.merge loc defs); };
  });
in toString (genMerge.evalModuleTree { } [
    { options.o = genMerge.mkOption { type = chain; }; }
    { o.foo.j.k.a = 1; o.bar.j.k.a = 2; o.baz.j.k.a = 3; }
  ]).config.o.foo.j.k.a'
row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_readsunplanted="${row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_reads/MERGE/swap}"
row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_readsbyvalue='v: if (v.baz.j.k.a or 0) == 3 then v else swap v'
row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_readsplanted="${row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_reads/MERGE/$row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_readsbyvalue}"
check "T5 a-value-reading-merge-below-a-foreign-chain-node-is-refused-where-it-reads unplanted (a merge swapping two keys' trees serves the moved tree)" \
  "$row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_readsunplanted" 0 "" \
  "$tmpdir/a-value-reading-merge-below-a-foreign-chain-node-is-refused-where-it-reads-green.err" '2'
check "T5 a-value-reading-merge-below-a-foreign-chain-node-is-refused-where-it-reads planted   (a merge deciding the swap on an element's value is refused where it reads)" \
  "$row_a_value_reading_merge_below_a_foreign_chain_node_is_refused_where_it_readsplanted" 1 \
  "at option \`o.baz.j': the option type \`unique' reads its elements' values in its merge, and over this evaluation's values it reached this element, placed at the key read or read while deciding placement" \
  "$tmpdir/a-value-reading-merge-below-a-foreign-chain-node-is-refused-where-it-reads-red.err"
