# `foreign-chain-strict-keyed` — foreign-chain-through-a-nullOr-or-a-strict-step-is-keyed-without-its-siblings,
# den-hoag-i01nx (ADR-0039, the serve half; ADR-0025 item 1). A foreign chain whose step is a strict
# `attrsWith` (at the option's own level, under `uniq`, or below a lazy step), or whose lazy step
# sits under a `nullOr`, is keyed by its stated steps: `nullOr` is a step-free wrapper and every
# `attrsWith` a step, so each key is read only where it is read. A key below the lazy step `mkIf`
# on the read tree, where it aborted uncatchably, and a sibling of another type, where it was
# refused, read nixpkgs' value. A stock-named strict step whose merge was overridden to swap two
# keys' trees, or to add a key to each tree, is refused by name (the stated price), never served a
# wrong value.

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
  strict =
    e:
    np.attrsWith {
      elemType = e;
      lazy = false;
      placeholder = "p";
    };
  cfg =
    type: defs:
    (genMerge.evalModuleTree { } ([ { options.o = genMerge.mkOption { inherit type; }; } ] ++ defs))
    .config.o;
  # the option's own strict step over a lazy step; the same under `uniq`; a strict step below a lazy one
  s1 = strict (np.lazyAttrsOf el);
  s7 = strict (np.uniq (np.lazyAttrsOf el));
  s6 = np.uniq (np.lazyAttrsOf (strict (np.lazyAttrsOf el)));
  # a key `i` below the lazy step, `mkIf` on the read tree, at `path`
  inner = path: [
    (
      { config, ... }:
      {
        config.o = lib.setAttrByPath path {
          j.k.a = 1;
          i = genMerge.mkIf ((lib.getAttrFromPath path config.o).j.k.a == 1) { k.a = 2; };
        };
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
  swap =
    v:
    v
    // {
      foo = v.bar;
      bar = v.foo;
    };
  addExtra = builtins.mapAttrs (_: v: v // { extra = 1; });
  two = [
    {
      config.o = {
        foo.j.k.a = 1;
        bar.j.k.a = 2;
      };
    }
  ];
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
in
{
  construct = [ "foreign-chain-through-a-nullOr-or-a-strict-step-is-keyed-without-its-siblings" ];
  check = asserts (
    (cfg s1 (inner [ "foo" ])).foo.j.k.a == 1
    && (cfg s7 (inner [ "foo" ])).foo.j.k.a == 1
    && (cfg s6 (inner [ "y" "foo" ])).y.foo.j.k.a == 1
    # `nullOr` over the lazy step, with a key set reading the read tree
    &&
      (cfg (np.uniq (np.nullOr (np.lazyAttrsOf (np.attrsOf el)))) [
        (
          { config, ... }:
          {
            config.o = {
              foo.j.k.a = 1;
              bar = if config.o.foo.j.k.a == 1 then { j.k.a = 2; } else { };
            };
          }
        )
      ]).foo.j.k.a == 1
    # a sibling of another type is not forced by the read, as nixpkgs' strict merge does not force it
    &&
      (cfg s1 [
        { config.o.foo.j.k.a = 1; }
        { config.o.bar = "x"; }
      ]).foo.j.k.a == 1
    &&
      (cfg s7 [
        { config.o.foo.j.k.a = 1; }
        { config.o.bar = "x"; }
      ]).foo.j.k.a == 1
    &&
      (cfg s6 [
        {
          config.o.y = {
            foo.j.k.a = 1;
            bar = "x";
          };
        }
      ]).y.foo.j.k.a == 1
    # a `nullOr` sibling defined both `null` and a tree
    &&
      (cfg (strict (np.nullOr (np.lazyAttrsOf el))) [
        { config.o.foo.j.k.a = 1; }
        { config.o.bar = null; }
        { config.o.bar.j.k.a = 2; }
      ]).foo.j.k.a == 1
    && refused (cfg (reshaped swap s1) two).foo.j.k.a
    && refused (cfg (reshaped addExtra s1) two)
  );
}
