# `overridden-container-folds-by-its-own-merge` — an-overridden-container-folds-by-its-own-merge,
# den-hoag-e12ro (ADR-0039, the serve half; ADR-0025 item 1). A nixpkgs `lazyAttrsOf` over a gen
# nested type, its `merge` overridden to swap two keys and its `substSubModules` forwarding the
# override (so nixpkgs' own mount keeps it), reads the swapped value and a definition conditional on
# the key the swap moves as the cell's own `lib.evalModules` reference does, where gen-merge re-homed
# it by its functor name, served the stock value silently and aborted on the conditional definition.

{
  asserts,
  genMerge,
  lib,
}:

let
  np = lib.types;
  kept =
    h: a:
    a
    // {
      merge = loc: defs: h (a.merge loc defs);
      substSubModules = m: kept h (a.substSubModules m);
    };
  swap =
    r:
    r
    // {
      foo = r.bar;
      bar = r.foo;
    };
  # one fixture, two engines: gen-merge's `evalModuleTree` with a gen element, and `lib.evalModules`
  # with nixpkgs' own
  run =
    gen: bar:
    let
      T = if gen then genMerge.types else np;
      mkOption = if gen then genMerge.mkOption else lib.mkOption;
      sub = T.submodule {
        options.a = mkOption {
          type = T.int;
          default = 0;
        };
      };
      modules = [
        { options.s = mkOption { type = kept swap (np.lazyAttrsOf (T.attrsOf sub)); }; }
        { config.s.foo.k.a = 1; }
        (args: { config.s.bar = bar (if gen then genMerge.mkIf else lib.mkIf) args; })
      ];
      cfg =
        if gen then
          (genMerge.evalModuleTree { } modules).config
        else
          (lib.evalModules { inherit modules; }).config;
    in
    {
      foo = cfg.s.foo.k.a;
      bar = cfg.s.bar.k.a;
    };
  plain = _: _: { k.a = 2; };
  # `bar` defined only where the value read at `bar` is positive: the override serves `foo`'s there
  selfConditional = mkIf: { config, ... }: mkIf (config.s.bar.k.a > 0) { k.a = 2; };
in
{
  construct = [ "an-overridden-container-folds-by-its-own-merge" ];
  check = asserts (
    run true plain == run false plain
    && run true selfConditional == run false selfConditional
    # the reference serves the override, so the comparison is not vacuous
    &&
      run false plain == {
        foo = 2;
        bar = 1;
      }
    &&
      run false selfConditional == {
        foo = 2;
        bar = 1;
      }
  );
}
