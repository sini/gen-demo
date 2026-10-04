# `lazy-container-node` — C93, den-hoag-9d80v. A container of nested trees under `lazyAttrsOf`
# (S1 class (a)) answers as nixpkgs does: its position is a container node, whose own key walk reads
# only that position's definitions, so `o.foo.a` is keyed and evaluated without reading `o.bar`,
# whose definition throws. It reads the value through the fold, never a node's `result` by
# identifier: a container node's `result` is a value, not a tree.
{ asserts, genMerge }:
{
  construct = [ "C93" ];
  check = asserts (
    let
      cfg =
        (genMerge.evalModuleTree { } [
          {
            options.o = genMerge.mkOption {
              type = genMerge.types.lazyAttrsOf (
                genMerge.types.attrsOf (
                  genMerge.types.submodule (
                    { name, ... }:
                    {
                      options.x = genMerge.mkOption { type = genMerge.types.int; };
                      options.n = genMerge.mkOption {
                        type = genMerge.types.str;
                        default = name;
                      };
                    }
                  )
                )
              );
            };
            config.o.foo.a.x = 1;
            config.o.bar = throw "sibling read";
          }
        ]).config;
    in
    cfg.o.foo.a.x == 1 && cfg.o.foo.a.n == "a"
  );
}
