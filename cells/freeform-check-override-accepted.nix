# `freeform-check-override-accepted` — C82, den-hoag-foreign-leaf-check-unenforced-v4h7k. A nixpkgs
# type given `// { check = _: false; }` and used as a tree's `freeformType` folds the undeclared plane
# by its raw `merge`, as nixpkgs' `lib.evalModules` does (`freeformType.merge prefix defs`, no check):
# `picks = 1` reads `{ picks = 1; }` under the v2 `attrsOf int` and the non-v2 `attrs`, where gen-merge
# refused both. The same two types at a declared option are still refused (C41's and C61's half),
# beside the stock types reading `{ picks = 1; }` there, so neither a fold that accepts every override
# nor one that refuses every override can pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  T = lib.types;
  overridden = {
    v2 = T.attrsOf T.int // {
      check = _: false;
    };
    plain = T.attrs // {
      check = _: false;
    };
  };
  picks = {
    _file = "/demo/picks.nix";
    picks = 1;
  };
  attempt = v: builtins.tryEval (builtins.deepSeq v v);
  asFreeform =
    type:
    attempt
      (genMerge.evalModuleTree {
        modules = [
          { freeformType = type; }
          picks
        ];
      }).config;
  asDeclared =
    type:
    attempt
      (genMerge.evalModuleTree {
        modules = [
          { options.spool = genMerge.mkOption { inherit type; }; }
          {
            _file = "/demo/spool.nix";
            spool = {
              picks = 1;
            };
          }
        ];
      }).config.spool;
  reads = r: r.success && r.value == { picks = 1; };
in
{
  construct = [ "C82" ];
  check = asserts (
    reads (asFreeform overridden.v2)
    && reads (asFreeform overridden.plain)
    && !(asDeclared overridden.v2).success
    && !(asDeclared overridden.plain).success
    && reads (asDeclared (T.attrsOf T.int))
    && reads (asDeclared T.attrs)
  );
}
