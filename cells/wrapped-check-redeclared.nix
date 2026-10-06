# `wrapped-check-redeclared` — C117, den-hoag-lsmnv. An option declared twice with one wrapped value,
# nixpkgs `addCheck` over gen-merge's `int`, keeps the added check: it refuses `5` and reads `2`, where
# gen-merge used to merge to bare `int` and serve `5`. Declared beside plain `int`, in either order,
# the merge would drop the check, so it is refused; that message is `refusals` row 129's. The shared
# value reading `2` is the passing twin, so a fold refusing every redeclaration cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types
      ++ [
        { spool = v; }
      ]
    )).config.spool;
  refused = types: v: !(builtins.tryEval (builtins.deepSeq (read types v) null)).success;
  short = lib.types.addCheck genMerge.types.int (n: n < 3);
in
{
  construct = [ "wrapped-value-declared-twice-keeps-its-check" ];
  check = asserts (
    read [ short short ] 2 == 2
    && refused [ short short ] 5
    && refused [ genMerge.types.int short ] 2
    && refused [ short genMerge.types.int ] 2
  );
}
