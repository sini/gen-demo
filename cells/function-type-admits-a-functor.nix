# `function-type-admits-a-functor` — C149, den-hoag-b5qdr, extended by den-hoag-b6nyh. A nixpkgs
# `setFunctionArgs` wrapper, the shape a lowering puts around a function, is a function to nixpkgs'
# `lib.isFunction`, the check its own `types.functionTo` runs. A gen-merge option of type `function`
# defined as that wrapper is served, and applied it answers what the same definition answers under
# nixpkgs' `functionTo`, where gen-types' `function` refused it with `builtins.isFunction`. So are a
# `setFunctionArgs` over a `setFunctionArgs` (a lowering wrapping a wrapped function) and a functor
# whose `__functor` is itself a functor, which nixpkgs #574597 serves again. A functor whose
# `__functor` is not a function is refused on both engines, which is the control. A self-returning
# functor is refused natively by name; nixpkgs overflows on it, so its nixpkgs arm is not evaluated.
{
  asserts,
  genMerge,
  lib,
}:
let
  leaf = { shuttle, ... }: shuttle;
  wrapped = lib.setFunctionArgs leaf { shuttle = false; };
  doubleWrapped = lib.setFunctionArgs wrapped { shuttle = false; };
  nested = {
    __functor = {
      __functor = _: _: leaf;
    };
  };
  notCallable = {
    __functor = 5;
  };
  selfReturning = {
    __functor = self: self;
  };
  loom =
    eval: mkOption: type: v:
    builtins.tryEval (
      (eval {
        modules = [
          { options.loom = mkOption { inherit type; }; }
          { loom = v; }
        ];
      }).config.loom
        {
          shuttle = "weft";
        }
    );
  native = loom (
    r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
  ) genMerge.mkOption genMerge.types.function;
  nixpkgs = loom lib.evalModules lib.mkOption (lib.types.functionTo lib.types.raw);
  served =
    v:
    nixpkgs v == {
      success = true;
      value = "weft";
    }
    && native v == nixpkgs v;
in
{
  construct = [ "functor-is-a-function-to-the-function-type" ];
  check = asserts (
    served wrapped
    && served doubleWrapped
    && served nested
    && !(nixpkgs notCallable).success
    && !(native notCallable).success
    && !(native selfReturning).success
  );
}
