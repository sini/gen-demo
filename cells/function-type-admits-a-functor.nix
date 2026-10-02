# `function-type-admits-a-functor` — C149, den-hoag-b5qdr. A nixpkgs `setFunctionArgs` wrapper, the shape a
# lowering puts around a function, is a function to nixpkgs' `lib.isFunction`, the check its own
# `types.functionTo` runs. A gen-merge option of type `function` defined as that wrapper is served,
# and applied it answers what the same definition answers under nixpkgs' `functionTo`, where
# gen-types' `function` refused it with `builtins.isFunction`. A functor whose `__functor` is not a
# function is refused on both engines, which is the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  wrapped = lib.setFunctionArgs ({ shuttle, ... }: shuttle) { shuttle = false; };
  notCallable = {
    __functor = 5;
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
  native = loom genMerge.evalModuleTree genMerge.mkOption genMerge.types.function;
  nixpkgs = loom lib.evalModules lib.mkOption (lib.types.functionTo lib.types.raw);
in
{
  construct = [ "C149" ];
  check = asserts (
    nixpkgs wrapped == {
      success = true;
      value = "weft";
    }
    && native wrapped == nixpkgs wrapped
    && !(nixpkgs notCallable).success
    && !(native notCallable).success
  );
}
