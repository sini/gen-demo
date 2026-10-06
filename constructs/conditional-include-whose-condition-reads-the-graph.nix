# ── C200 — a conditional include whose condition reads the graph (gen-rules; den-hoag-1wdng). Under
# C197's mounted cnf, `hem` is a module function holding a closure over `thimble`, and `trim` includes
# `{ description = "trimmed"; }` only when `hem`'s door node fires to `"hem-pewter"` at
# `thimble = "pewter"`, read through the one root table and door inside the same evaluation. Reading
# `trim` forces its condition, which fires `hem`; firing `hem` reads `hem`'s table along its own position
# and never `trim`'s `includes`, so the program has no cycle. `trimControl` is the same text with the
# condition `true`. Before, the root table united every aspect's table, so any read of it forced every
# include's condition, `trim`'s included, and the evaluation recursed infinitely.
{
  genRules,
  genAspects,
  genMerge,
  inputs,
}:
let
  D = [ "thimble" ];
  cnf = {
    entityKinds = D;
    keySemantics.nixos.category = "class";
    moduleArgs = {
      config = true;
      pkgs = true;
    };
    aspectModules = [ (genRules.lambdasMount "lambdas") ];
  };
  load = genRules.defunctionalize {
    inherit cnf;
    declared = D;
    key = "gen-demo:c200";
    lambdasPath = [ "lambdas" ];
    aspectPaths = [ [ "aspects" ] ];
  };
  inherit (inputs.gen.lib.substrate.identity) hashIdentity;
  src = k: hashIdentity "entity" [ "name" ] (_: k);
  # `a`'s door node fired at `thimble = "pewter"`, through the door over `config`'s own root table
  fireIn =
    config: a:
    (genAspects.mkGuardVocab (
      cnf
      // {
        ref = genRules.mkApply {
          inherit (config) lambdas;
          inherit cnf;
          declared = D;
        };
      }
    )).applyGuardWith
      {
        context.thimble = "pewter";
        sources.thimble = src "pewter";
        scope = { };
      }
      (
        builtins.head (
          builtins.filter (x: builtins.isAttrs x && (x.__guard or false)) config.aspects.${a}.includes
        )
      );
  tree = genMerge.evalModuleTree { } [
    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load (
      { config, ... }:
      {
        aspects.hem =
          { config, ... }:
          {
            includes = [ ({ thimble, ... }: { description = "hem-${thimble}"; }) ];
          };
        aspects.trim.includes = genMerge.mkIf ((fireIn config "hem").description == "hem-pewter") [
          { description = "trimmed"; }
        ];
        aspects.trimControl.includes = genMerge.mkIf true [ { description = "trimmed"; } ];
      }
    ))
  ];
  descriptions = a: map (x: x.description or "guard") tree.config.aspects.${a}.includes;
in
{
  c200Hem = (fireIn tree.config "hem").description;
  c200Trim = descriptions "trim";
  c200TrimControl = descriptions "trimControl";
}
