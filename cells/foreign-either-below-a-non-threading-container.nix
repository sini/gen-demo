# `foreign-either-below-a-non-threading-container` — den-hoag-p06j3 (ADR-0039, the serve half;
# ADR-0025 item 1). nixpkgs' `either` and `oneOf` holding a gen submodule are served at the option's
# root and under the six containers gen-merge re-homes, and so is a gen `either` under `coercedTo`.
# Below nixpkgs' own `coercedTo` or `uniq`, which do not thread the evaluation to a nested tree, the
# foreign `either` is refused by name where nixpkgs serves the value: an open defect (the parity-defect
# rule, 2026-10-09, rule 1; owner-ruled 2026-10-10 that no threading door lands), not a price. Each
# row is read on both sides, nixpkgs' value from `lib.evalModules` over nixpkgs' own submodule, so the
# cell goes red when gen starts serving a row, and the controls show the refusal reading is false
# where gen serves.
{
  asserts,
  genMerge,
  lib,
}:
let
  np = lib.types;
  t = genMerge.types;
  gSub = t.submodule {
    options.a = genMerge.mkOption {
      type = t.int;
      default = 0;
    };
  };
  nSub = np.submodule {
    options.a = lib.mkOption {
      type = np.int;
      default = 0;
    };
  };
  cf = _: throw "coerced";
  rows = {
    coercedTo-either = _: G: np.coercedTo np.int cf (np.either G np.str);
    coercedTo-oneOf =
      _: G:
      np.coercedTo np.int cf (
        np.oneOf [
          np.str
          np.bool
          G
        ]
      );
    uniq-either = _: G: np.uniq (np.either G np.str);
    uniq-oneOf =
      _: G:
      np.uniq (
        np.oneOf [
          np.str
          np.bool
          G
        ]
      );
  };
  controls = {
    either-at-the-root = _: G: np.either G np.str;
    gen-either-under-coercedTo = E: G: np.coercedTo np.int cf (E.either G np.str);
  };
  genRead =
    ty:
    (genMerge.evalModuleTree { } [
      { options.h = genMerge.mkOption { type = ty; }; }
      { h.a = 1; }
    ]).config.h.a;
  npRead =
    ty:
    (lib.evalModules {
      modules = [
        { options.h = lib.mkOption { type = ty; }; }
        { h.a = 1; }
      ];
    }).config.h.a;
  refuses = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  open = r: npRead (r np nSub) == 1 && refuses (genRead (r t gSub));
  served = r: npRead (r np nSub) == 1 && genRead (r t gSub) == 1;
in
{
  construct = [ "foreign-either-below-a-non-threading-container-is-an-open-defect" ];
  check = asserts (
    builtins.all open (builtins.attrValues rows) && builtins.all served (builtins.attrValues controls)
  );
}
