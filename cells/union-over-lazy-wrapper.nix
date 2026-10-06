# `union-over-lazy-wrapper` — C130, den-hoag-native-container-walk-either-abort-4zvc9 (Unit 1). A gen
# `either` over `lazyAttrsOf` of a nixpkgs `uniq` or `coercedTo` wrapper of a gen submodule, in
# gen-merge's own `evalModuleTree`, gives nixpkgs' value for the same construction over its own types.
# The union's walk mints a container node at the lazy position and the fold reads that node; the
# member chain used to descend through the wrapper past it, and the read aborted on `attribute
# 'value' missing`, which `tryEval` does not catch. Both wrappers, because each splits with the
# empty step the chain used to follow.
{
  asserts,
  genMerge,
  lib,
}:
let
  wrappers = {
    uniq = lib.types.uniq;
    coercedTo = lib.types.coercedTo lib.types.str (_: throw "unused");
  };
  # `P` is the type vocabulary and `mkOption` its option constructor; the leaf is one int option.
  value =
    eval: P: mkOption: wrap:
    (eval {
      modules = [
        {
          options.heddle = mkOption {
            type = P.either (P.lazyAttrsOf (
              wrap (P.submodule { options.x = mkOption { type = P.int; }; })
            )) P.str;
          };
        }
        { config.heddle.k.x = 5; }
      ];
    }).config.heddle;
  holds =
    wrap:
    value (
      r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
    ) genMerge.types genMerge.mkOption wrap == value lib.evalModules lib.types lib.mkOption wrap;
in
{
  construct = [ "union-over-a-lazy-wrapper-serves-nixpkgs-value" ];
  check = asserts (holds wrappers.uniq && holds wrappers.coercedTo);
}
