# ── C162 — a nullable hem (den-hoag-azdne). One option of gen-merge's `nullOr int` and one of
# nixpkgs' own `nullOr int`, each read over a list of definitions as its engine's `tryEval` record.
{ genMerge, lib }:
let
  hem =
    evalModules: mkOption: type: defs:
    builtins.tryEval
      (evalModules {
        modules = [ { options.hem = mkOption { inherit type; }; } ] ++ map (v: { hem = v; }) defs;
      }).config.hem;
in
{
  nullableHem = hem genMerge.evalModuleTree genMerge.mkOption (
    genMerge.types.nullOr genMerge.types.int
  );
  nullableHemNixpkgs = hem lib.evalModules lib.mkOption (lib.types.nullOr lib.types.int);
}
