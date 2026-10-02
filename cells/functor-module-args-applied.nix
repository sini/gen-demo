# `functor-module-args-applied` — C135, den-hoag-genmerge-functor-module-application-u6lf8. A
# nixpkgs `setFunctionArgs`-wrapped `{ myArg, ... }:` module, the wrapper a lowering puts around a
# module function, is a function module to nixpkgs: it is applied by its published `__functionArgs`,
# and `myArg` is served from `_module.args`. Through gen-merge's `evalModuleTree` it reads the value
# nixpkgs' own `lib.evalModules` gives on the same module value, where gen-merge unwrapped the functor,
# applied it to the base set only and aborted uncatchably, `called without required argument
# 'myArg'`. The unwrapped module, read on both engines, is the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  argsMod = {
    config._module.args.myArg = "from-module-args";
  };
  onArg = { myArg, ... }: { config.x = myArg; };
  wrapped = lib.setFunctionArgs (args: onArg args) (builtins.functionArgs onArg);
  withArgs = m: [
    argsMod
    m
  ];
  x =
    eval: mkOption: P: mods:
    (eval { modules = [ { options.x = mkOption { type = P.str; }; } ] ++ mods; }).config.x;
  nixpkgs = x lib.evalModules lib.mkOption lib.types;
  native = x genMerge.evalModuleTree genMerge.mkOption genMerge.types;
in
{
  construct = [ "C135" ];
  check = asserts (
    nixpkgs (withArgs wrapped) == "from-module-args"
    && native (withArgs wrapped) == nixpkgs (withArgs wrapped)
    && native (withArgs onArg) == nixpkgs (withArgs onArg)
  );
}
