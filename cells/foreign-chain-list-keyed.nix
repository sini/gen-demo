# `foreign-chain-list-keyed` — foreign-chain-with-a-stock-list-step-is-keyed-from-its-definitions,
# den-hoag-obi4j (ADR-0039, the serve half; ADR-0025 item 1). A foreign chain whose `listOf` step
# sits under a step-free wrapper (`coercedTo`), over a record that may nest, is keyed by its
# positions, the `[definition n-entry m]` segments nixpkgs' merge names, read off the definitions
# the step folds. That is sound only where stock code folds them, so the step is a level only where
# every record on the chain is its own functor's build (its merge bound where a fresh build binds
# it). A key below the list's element `mkIf` on the read tree, where it aborted uncatchably, reads
# nixpkgs' value. A `listOf` whose merge was overridden to reverse its elements is not witnessed
# stock, keeps the eager walk, and serves nixpkgs' value.

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
  };
  el = t.attrsOf sub;
  co = np.coercedTo np.str (_: throw "unused");
  cfg =
    type: defs:
    (genMerge.evalModuleTree { } ([ { options.o = genMerge.mkOption { inherit type; }; } ] ++ defs))
    .config.o;
  read = o: (builtins.head o).j.k.a;
  # the first element's own key `i`, `mkIf` on the read tree
  inner = [
    (
      { config, ... }:
      {
        config.o = [
          {
            j.k.a = 1;
            i = genMerge.mkIf (read config.o == 1) { k.a = 2; };
          }
        ];
      }
    )
  ];
  # a second element's key `i`, `mkIf` on the read tree
  sibling = [
    (
      { config, ... }:
      {
        config.o = [
          { j.k.a = 1; }
          {
            j.k.a = 2;
            i = genMerge.mkIf (read config.o == 1) { k.a = 3; };
          }
        ];
      }
    )
  ];
  reshaped =
    g: a:
    a
    // {
      merge = loc: defs: g (a.merge loc defs);
      substSubModules =
        m:
        let
          r = a.substSubModules m;
        in
        r // { merge = loc: defs: g (r.merge loc defs); };
    };
in
{
  construct = [ "foreign-chain-with-a-stock-list-step-is-keyed-from-its-definitions" ];
  check = asserts (
    read (cfg (co (np.listOf (np.lazyAttrsOf el))) inner) == 1
    && read (cfg (co (np.listOf (np.lazyAttrsOf el))) sibling) == 1
    && read (cfg (co (np.listOf (np.nullOr (np.lazyAttrsOf el)))) inner) == 1
    # an overridden `listOf` is not witnessed stock: the eager walk serves its reversed value
    &&
      map (x: x.j.k.a) (
        cfg (co (reshaped lib.reverseList (np.listOf (np.lazyAttrsOf el)))) [
          {
            config.o = [
              { j.k.a = 1; }
              { j.k.a = 2; }
            ];
          }
        ]
      ) == [
        2
        1
      ]
  );
}
