# `functor-module-bound` — C146, den-hoag-k5ohf. A nixpkgs `setFunctionArgs`-wrapped `{ myArg, ... }:`
# module is a function module to nixpkgs (`lib.isFunction`), and gen-bind's `wrap` binds `myArg` into
# it exactly as into the lambda it wraps: the wrapped module is marked wrapped, and nixpkgs' own
# `lib.evalModules` reads the bound value from it, the value nixpkgs serves the unwrapped module from
# `_module.args`. gen-bind passed the functor through unbound and the evaluation aborted on the
# missing `myArg`. The lambda, wrapped and evaluated the same way, is the control.
{
  asserts,
  genBind,
  lib,
}:
let
  onArg = { myArg, ... }: { config.x = myArg; };
  published = lib.setFunctionArgs (args: onArg args) (builtins.functionArgs onArg);
  bind = genBind.wrap { bindings.myArg = "bound"; };
  x =
    mods:
    (lib.evalModules { modules = [ { options.x = lib.mkOption { type = lib.types.str; }; } ] ++ mods; })
    .config.x;
  served =
    m:
    x [
      m
      { config._module.args.myArg = "bound"; }
    ];
in
{
  construct = [ "functor-module-is-bound-as-its-lambda" ];
  check = asserts (
    (bind published).wrapped
    && x [ (bind published).module ] == served published
    && (bind onArg).wrapped
    && x [ (bind onArg).module ] == served onArg
  );
}
