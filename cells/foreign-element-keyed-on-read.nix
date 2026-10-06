# `foreign-element-keyed-on-read` — C147, den-hoag-i2xjs.
# A gen `attrsOf` whose element is a nixpkgs `coercedTo` or `uniq` wrapper of a gen submodule, in
# gen-merge's own `evalModuleTree`, gives nixpkgs' value for the same construction over its own
# types at a key holding a tree, while a sibling key's definitions are outside the wrapper's domain
# (an int the coercion does not take; two definitions under `uniq`). The sibling refuses catchably
# on both engines. Each element is a container node, keyed where it is read, so the read of one key
# never runs a sibling's merge; gen-merge used to abort the read uncatchably, or refuse it with the
# sibling's own error.
{
  asserts,
  genMerge,
  lib,
}:
let
  wrappers = {
    coercedTo = {
      wrap = lib.types.coercedTo lib.types.str (s: {
        x = lib.stringLength s;
      });
      defs = [
        {
          k.x = 5;
          n = 5;
        }
      ];
    };
    uniq = {
      wrap = lib.types.uniq;
      defs = [
        {
          k.x = 5;
          n.x = 1;
        }
        { n.x = 2; }
      ];
    };
  };
  # `P` is the type vocabulary and `mkOption` its option constructor; the leaf is one int option.
  value =
    eval: P: mkOption: w:
    (eval {
      modules = [
        {
          options.heddle = mkOption {
            type = P.attrsOf (w.wrap (P.submodule { options.x = mkOption { type = P.int; }; }));
          };
        }
      ]
      ++ map (d: { config.heddle = d; }) w.defs;
    }).config.heddle;
  gen = value (
    r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
  ) genMerge.types genMerge.mkOption;
  nixpkgs = value lib.evalModules lib.types lib.mkOption;
  refuses = v: !(builtins.tryEval (builtins.deepSeq v.n true)).success;
  holds = w: (gen w).k == (nixpkgs w).k && refuses (gen w) && refuses (nixpkgs w);
in
{
  construct = [ "foreign-element-is-keyed-where-it-is-read" ];
  check = asserts (holds wrappers.coercedTo && holds wrappers.uniq);
}
