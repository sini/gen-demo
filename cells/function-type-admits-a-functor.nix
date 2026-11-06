# `function-type-admits-a-functor` — C149, den-hoag-b5qdr, extended by den-hoag-b6nyh. A nixpkgs
# `setFunctionArgs` wrapper, the shape a lowering puts around a function, is a function to nixpkgs'
# `lib.isFunction`, the check its own `types.functionTo` runs. A gen-merge option of type `function`
# defined as that wrapper is served, and applied it answers what the same definition answers under
# nixpkgs' `functionTo`, where gen-types' `function` refused it with `builtins.isFunction`. So are a
# `setFunctionArgs` over a `setFunctionArgs` (a lowering wrapping a wrapped function) and a functor
# whose `__functor` is itself a functor, which nixpkgs #574597 serves again. A functor whose
# `__functor` is not a function is refused on both engines, which is the control. A self-returning
# functor is refused natively by name; nixpkgs overflows on it, so its nixpkgs arm is not evaluated.
# The same two values, each defined twice under a type stated as `mkOptionType { name; }`, meet the
# default merge (`mergeDefaultOption`), whose function arm is chosen by gen-prelude's `isFunction`:
# both engines merge them pointwise, and the self-returning functor is refused there by name.
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
  # Two definitions of one option whose type takes the default merge, applied to one argument.
  twice =
    eval: mkOptionType: v:
    builtins.tryEval (
      (eval {
        modules = [
          { options.loom = mkOptionType { name = "loom"; }; }
          { loom = v; }
          { loom = v; }
        ];
      }).config.loom
        {
          shuttle = "weft";
        }
    );
  nativeTwice = twice (r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules) (
    t: genMerge.mkOption { type = genMerge.mkOptionType t; }
  );
  nixpkgsTwice = twice lib.evalModules (t: lib.mkOption { type = lib.mkOptionType t; });
  pointwise =
    v:
    nixpkgsTwice v == {
      success = true;
      value = "weftweft";
    }
    && nativeTwice v == nixpkgsTwice v;
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
    && pointwise doubleWrapped
    && pointwise nested
    && !(nativeTwice selfReturning).success
  );
}
