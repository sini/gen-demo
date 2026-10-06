{
  title = "a functor module is applied by its formals";
  adr = "0025 item 1, u6lf8";
  what = "`functor-module-args-applied`: a nixpkgs `setFunctionArgs`-wrapped `{ myArg, ... }:` module whose `myArg` is a `_module.args` value reads `from-module-args` through gen-merge's `evalModuleTree`, nixpkgs' own `lib.evalModules` value on the same module value, where gen-merge unwrapped the functor and aborted uncatchably on `called without required argument 'myArg'`; the unwrapped module, equal on both engines, is the control";
}
