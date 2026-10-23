# `a-rewrapped-partial-output-reads-the-module-arguments` — den-hoag-fully-bound-functor-call-args-vsu8s.
# gen-bind's partial output over a `{ host, user, ... }:` module, with `user` bound, is wrapped again
# with `host` bound. The module still reads the module system's own arguments (`config`, `lib`,
# `options`, a caller's `specialArgs`) under nixpkgs' `lib.evalModules`, as the unwrapped module does
# when nixpkgs serves `host` and `user`. gen-bind called it with `host` and `user` alone. The closed
# `{ host, user }:` twin, which nixpkgs refuses for the extra `lib`, is still called with its formals
# alone and serves them.
{
  asserts,
  genBind,
  lib,
}:
let
  decl = {
    options.seen = lib.mkOption { type = lib.types.raw; };
    options.x = lib.mkOption {
      type = lib.types.str;
      default = "cx";
    };
  };
  open =
    a@{ host, user, ... }:
    {
      config.seen = {
        names = builtins.attrNames a;
        x = a.config.x;
        extra = a.extra;
      };
    };
  closed = { host, user }: { config.seen = host + user; };
  seen =
    modules: specialArgs:
    (lib.evalModules {
      modules = [ decl ] ++ modules;
      inherit specialArgs;
    }).config.seen;
  rewrap = m: (genBind.wrap { bindings.host = "h"; } (genBind.wrap { bindings.user = "u"; } m).module).module;
in
{
  construct = [ "a-rewrapped-partial-output-reads-the-module-arguments" ];
  check = asserts (
    seen [ (rewrap open) ] { extra = "sa"; } == seen [ open ] {
      host = "h";
      user = "u";
      extra = "sa";
    }
    && seen [ (rewrap closed) ] { } == "hu"
  );
}
