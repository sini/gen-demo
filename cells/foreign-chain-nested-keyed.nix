# `foreign-chain-nested-keyed` — foreign-chain-with-a-step-below-its-lazy-attrswith-is-keyed-without-its-siblings,
# den-hoag-rlskz (ADR-0039, the serve half; ADR-0025 item 1). A foreign chain whose lazy
# `attrsWith` holds, at each key, a record that is itself a container (`attrsOf`, `lazyAttrsOf`, at
# any depth) is keyed one key at a time: each key is a container node whose own walk is that
# record's, read off the merge's result at that key only. A sibling whose key set reads the read
# tree, an inner `mkIf` below the node, and siblings that add keys or are `mkIf` on another key's
# tree all read nixpkgs' value, where they aborted uncatchably. A merge overridden to swap two
# keys' trees is refused by name (the message is gen-merge's
# `testsError.nesting-keys-foreign-chain-nested`), never served a wrong value.

{
  asserts,
  genMerge,
  lib,
}:

let
  t = genMerge.types;
  np = lib.types;
  sub = t.submodule {
    options.a = genMerge.mkOption {
      type = t.int;
      default = 0;
    };
    options.b = genMerge.mkOption {
      type = t.int;
      default = 0;
    };
  };
  # the second step below the lazy one: `uniq (lazyAttrsOf (attrsOf (gen attrsOf sub)))`
  family2 = np.uniq (np.lazyAttrsOf (np.attrsOf (t.attrsOf sub)));
  cfg =
    type: defs:
    (genMerge.evalModuleTree { } ([ { options.o = genMerge.mkOption { inherit type; }; } ] ++ defs))
    .config.o;
  # `bar`'s key set reads the tree read at `foo`
  keysDep = d: read: [
    (
      { config, ... }:
      {
        config.o = {
          foo = d 1;
          bar = if read config.o.foo == 1 then d 2 else { };
        };
      }
    )
  ];
  # a stock-named `lazyAttrsOf` whose merge, its rebuild's included, swaps two keys' trees
  swap =
    v:
    v
    // {
      foo = v.bar;
      bar = v.foo;
    };
  lazy = np.lazyAttrsOf (np.attrsOf (t.attrsOf sub));
  swapped = np.uniq (
    lazy
    // {
      merge = loc: defs: swap (lazy.merge loc defs);
      substSubModules =
        m:
        let
          r = lazy.substSubModules m;
        in
        r // { merge = loc: defs: swap (r.merge loc defs); };
    }
  );
in
{
  construct = [ "foreign-chain-with-a-step-below-its-lazy-attrswith-is-keyed-without-its-siblings" ];
  check = asserts (
    (cfg family2 (keysDep (v: { j.k.a = v; }) (x: x.j.k.a))).foo.j.k.a == 1
    # three steps under `coercedTo`: each lazy step is a level of nodes
    &&
      (cfg (np.coercedTo np.str (_: throw "unused") (
        np.lazyAttrsOf (np.lazyAttrsOf (np.attrsOf (t.attrsOf sub)))
      )) (keysDep (v: { j.i.k.a = v; }) (x: x.j.i.k.a))).foo.j.i.k.a == 1
    # an inner lazy step below the node keys its own keys where read
    &&
      (cfg (np.uniq (np.lazyAttrsOf (np.lazyAttrsOf (t.attrsOf sub)))) [
        (
          { config, ... }:
          {
            config.o.foo = {
              j.k.a = 1;
              i = genMerge.mkIf (config.o.foo.j.k.a == 1) { k.a = 2; };
            };
          }
        )
      ]).foo.j.k.a == 1
    # the whole value under siblings that add keys, `mkIf` on another key's tree, a discharged key
    # and a key set reading `foo`: nixpkgs' value, every key it keeps and none it drops
    &&
      cfg family2 [
        (
          { config, ... }:
          let
            barA = config.o.bar.j.k.a;
          in
          {
            config.o = {
              foo = genMerge.mkMerge [
                { j.k.a = 1; }
                { j.k2.a = 2; }
                { j2.k.a = 3; }
                (genMerge.mkIf (barA == 5) { j.k3.a = 4; })
                { j.k5 = genMerge.mkIf (barA == 5) { b = 7; }; }
                { j.k6.a = genMerge.mkIf false 9; }
              ];
              bar.j.k.a = 5;
              baz = if config.o.foo.j.k.a == 1 then { j.k.a = 8; } else { };
            };
          }
        )
      ] == {
        foo.j = {
          k = {
            a = 1;
            b = 0;
          };
          k2 = {
            a = 2;
            b = 0;
          };
          k3 = {
            a = 4;
            b = 0;
          };
          k5 = {
            a = 0;
            b = 7;
          };
          k6 = {
            a = 0;
            b = 0;
          };
        };
        foo.j2.k = {
          a = 3;
          b = 0;
        };
        bar.j.k = {
          a = 5;
          b = 0;
        };
        baz.j.k = {
          a = 8;
          b = 0;
        };
      }
    && !(builtins.tryEval (
      builtins.deepSeq
        (cfg swapped [
          {
            config.o = {
              foo.j.k.a = 1;
              bar.j.k.a = 2;
            };
          }
        ]).foo.j.k.a
        null
    )).success
  );
}
