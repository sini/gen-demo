# `foreign-chain-keyed` — foreign-chain-over-a-lazy-attrswith-is-keyed-without-its-siblings,
# den-hoag-fozin (ADR-0039, the serve half; ADR-0025 item 1). A foreign chain of step-free wrappers
# (`unique`, `coercedTo`) over one lazy `attrsWith`, above a gen element that may nest, is keyed by
# the step its functors state: a sibling whose key set reads the read tree, or an alias of it, is no
# longer forced to key it, so the read serves nixpkgs' value where it aborted uncatchably. A merge
# overridden to move a key's tree to another key serves nixpkgs' value: the moved tree is the
# evaluation's own child, read where the merge put it (den-hoag-lif3n).

{
  asserts,
  genMerge,
  lib,
}:

let
  t = genMerge.types;
  np = lib.types;
  sub = t.submodule { options.x = genMerge.mkOption { type = t.int; }; };
  aw = np.attrsWith {
    elemType = t.attrsOf sub;
    lazy = true;
    placeholder = "p";
  };
  cfg =
    type: defs:
    (genMerge.evalModuleTree { } ([ { options.o = genMerge.mkOption { inherit type; }; } ] ++ defs))
    .config.o;
  two = [
    {
      config.o = {
        foo.k.x = 1;
        bar.k.x = 2;
      };
    }
  ];
  # a stock-named lazy `attrsWith` whose merge, its rebuild's included, swaps two keys' trees
  swap =
    v:
    v
    // {
      foo = v.bar;
      bar = v.foo;
    };
  swapped = np.uniq (
    aw
    // {
      merge = loc: defs: swap (aw.merge loc defs);
      substSubModules =
        m:
        let
          r = aw.substSubModules m;
        in
        r // { merge = loc: defs: swap (r.merge loc defs); };
    }
  );
in
{
  construct = [ "foreign-chain-over-a-lazy-attrswith-is-keyed-without-its-siblings" ];
  check = asserts (
    # `bar`'s key set reads the tree read at `foo`
    (cfg (np.uniq aw) [
      (
        { config, ... }:
        {
          config.o = {
            foo.k.x = 1;
            bar = if config.o.foo.k.x == 1 then { k.x = 2; } else { };
          };
        }
      )
    ]).foo.k.x == 1
    # `bar` is an alias of the tree read at `foo`
    &&
      (cfg (np.coercedTo np.str (_: throw "unused") (np.lazyAttrsOf (t.attrsOf sub))) [
        (
          { config, ... }:
          {
            config.o = {
              foo.k.x = 1;
              bar = config.o.foo;
            };
          }
        )
      ]).foo.k.x == 1
    &&
      cfg aw two == {
        foo.k.x = 1;
        bar.k.x = 2;
      }
    && (cfg swapped two).foo.k.x == 2
  );
}
