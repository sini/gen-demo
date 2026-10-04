# `union-element-container-node` — C134, den-hoag-native-container-walk-either-abort-4zvc9 (Unit 2).
# A gen `attrsOf` whose element is a gen `either` over a nixpkgs `uniq` or `coercedTo` wrapper of a
# gen submodule, in gen-merge's own `evalModuleTree`, gives nixpkgs' value for the same construction
# over its own types, at a key holding a tree and at a sibling key holding a string. Each element
# is a container node, keyed where it is read, and the fold reads that node; the walk used to drop
# the wrapper member, and the read refused with gen-scope's internal `getNta … no key`.
{
  asserts,
  genMerge,
  lib,
}:
let
  wrappers = {
    uniq = lib.types.uniq;
    # A string the coercion takes is coerced on both engines, as nixpkgs' `either` checks its first
    # member through the coercion.
    coercedTo = lib.types.coercedTo lib.types.str (s: {
      x = lib.stringLength s;
    });
  };
  # `P` is the type vocabulary and `mkOption` its option constructor; the leaf is one int option.
  value =
    eval: P: mkOption: wrap:
    (eval {
      modules = [
        {
          options.heddle = mkOption {
            type = P.attrsOf (P.either (wrap (P.submodule { options.x = mkOption { type = P.int; }; })) P.str);
          };
        }
        {
          config.heddle = {
            k.x = 5;
            s = "weft";
          };
        }
      ];
    }).config.heddle;
  holds =
    wrap:
    value (
      r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
    ) genMerge.types genMerge.mkOption wrap == value lib.evalModules lib.types lib.mkOption wrap;
in
{
  construct = [ "C134" ];
  check = asserts (holds wrappers.uniq && holds wrappers.coercedTo);
}
