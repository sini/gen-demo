{
  title = "a functor module is bound as its lambda";
  adr = "0025 item 1, k5ohf";
  what = "`functor-module-bound`: gen-bind's `wrap` binds `myArg` into a nixpkgs `setFunctionArgs`-wrapped `{ myArg, ... }:` module, marks it wrapped, and nixpkgs' own `lib.evalModules` reads `bound` from it, the value nixpkgs serves the unwrapped module from `_module.args`, where gen-bind passed the functor through unbound and the evaluation aborted on the missing `myArg`; the lambda, wrapped and evaluated the same way, is the control";
}
