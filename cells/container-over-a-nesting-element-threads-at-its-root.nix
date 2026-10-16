# `container-over-a-nesting-element-threads-at-its-root` — den-hoag-c922w. An option root reads, by presence, whether a
# container's element chain ends at a leaf, and does not walk a root that cannot nest. A container whose element
# nests still threads at its root: an `attrsOf (listOf submodule)` serves each element's submodule configuration, its
# defaults filled in beside what a definition sets, and the same holds one level shallower and under a `nullOr`. A
# leaf chain beside it, `attrsOf (listOf (nullOr int))`, is served as merged.
{
  asserts,
  genMerge,
  ...
}:
let
  t = genMerge.types;
  sub = t.submodule {
    options.y = genMerge.mkOption {
      type = t.int;
      default = 1;
    };
  };
  config =
    (genMerge.evalModuleTree { } [
      {
        options.nest = genMerge.mkOption { type = t.attrsOf (t.listOf sub); };
        options.list = genMerge.mkOption { type = t.listOf sub; };
        options.maybe = genMerge.mkOption { type = t.attrsOf (t.nullOr sub); };
        options.chain = genMerge.mkOption { type = t.attrsOf (t.listOf (t.nullOr t.int)); };
      }
      {
        nest.k = [
          { y = 2; }
          { }
        ];
        list = [ { } ];
        maybe.k = { };
        maybe.j = null;
        chain.k = [
          1
          null
        ];
      }
    ]).config;
  served =
    v: want:
    let
      r = builtins.tryEval (builtins.deepSeq v v);
    in
    r.success && r.value == want;
in
{
  construct = [ "a-container-over-a-nesting-element-threads-at-its-root" ];
  check = asserts (
    served config.nest {
      k = [
        { y = 2; }
        { y = 1; }
      ];
    }
    && served config.list [ { y = 1; } ]
    && served config.maybe {
      k = {
        y = 1;
      };
      j = null;
    }
    && served config.chain {
      k = [
        1
        null
      ];
    }
  );
}
