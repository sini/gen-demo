# `a-fully-bound-open-module-reads-the-module-arguments` — den-hoag-4uta7. A `{ host, ... }:` module whose
# every named formal gen-bind binds still reads the module system's own arguments (`config`, `lib`,
# `options`, a caller's `specialArgs`) under nixpkgs' `lib.evalModules`, as the unwrapped module does
# when nixpkgs serves `host`. gen-bind called it with the bound `host` alone. The closed `{ host }:`
# twin, which nixpkgs refuses for the extra `lib`, is still called with `host` alone and serves it.
{
  asserts,
  genBind,
  lib,
}:
let
  hostV.name = "h";
  decl = {
    options.seen = lib.mkOption { type = lib.types.raw; };
    options.x = lib.mkOption {
      type = lib.types.str;
      default = "cx";
    };
  };
  open =
    a@{ host, ... }:
    {
      config.seen = {
        names = builtins.attrNames a;
        x = a.config.x;
        extra = a.extra;
      };
    };
  closed = { host }: { config.seen = host.name; };
  seen =
    modules: specialArgs:
    (lib.evalModules {
      modules = [ decl ] ++ modules;
      inherit specialArgs;
    }).config.seen;
  bind = m: (genBind.wrap { bindings.host = hostV; } m).module;
in
{
  construct = [ "a-fully-bound-open-module-reads-the-module-arguments" ];
  check = asserts (
    seen [ (bind open) ] { extra = "sa"; } == seen [ open ] {
      host = hostV;
      extra = "sa";
    }
    && seen [ (bind closed) ] { } == "h"
  );
}
