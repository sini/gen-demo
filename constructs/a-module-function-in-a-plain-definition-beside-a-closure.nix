# ── a module function in a plain definition beside a closure (gen-rules + gen-aspects; den-hoag-3849t).
# Under C197's mounted cnf, two modules define `sleeve`: one writes the closure `tuck`, which gen-rules
# lowers into a door node, so `sleeve` is a guard carrier; the other is a PLAIN definition holding a
# module function in `includes` and another at the nested key `cuff`. gen-aspects types the plain
# definition's `includes` lists and coerces the nested key's function into that key's `includes`, in the
# carrier's one evaluation, so both functions' closures are registered where the root reaches them and
# fire. `sleeveControl` writes the same plain definition beside a plain description (no carrier).
# Before, the plain definition was held raw: its functions were never applied and were served raw.
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
  load =
    key:
    genRules.defunctionalize {
      inherit cnf key;
      declared = D;
      lambdasPath = [ "lambdas" ];
      aspectPaths = [ [ "aspects" ] ];
    };
  inherit (inputs.gen.lib.substrate.identity) hashIdentity;
  src = k: hashIdentity "entity" [ "name" ] (_: k);
  isGuard = x: builtins.isAttrs x && (x.__guard or false);
  tuck = { thimble, ... }: { description = "tuck-${thimble}"; };
  hem = { thimble, ... }: { description = "hem-${thimble}"; };
  cuff = { thimble, ... }: { description = "cuff-${thimble}"; };
  plain = {
    cuff = { config, ... }: { includes = [ cuff ]; };
    includes = [ ({ config, ... }: { includes = [ hem ]; }) ];
  };
  tree = genMerge.evalModuleTree { } [
    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load "gen-demo:sleeve:tuck" { aspects.sleeve = tuck; })
    (load "gen-demo:sleeve:plain" {
      aspects.sleeve = plain;
      aspects.sleeveControl = plain // {
        description = "control";
      };
    })
  ];
  fire =
    (genAspects.mkGuardVocab (
      cnf
      // {
        ref = genRules.mkApply {
          inherit (tree.config) lambdas;
          inherit cnf;
          declared = D;
        };
      }
    )).applyGuardWith
      {
        context.thimble = "pewter";
        sources.thimble = src "pewter";
        scope = { };
      };
  # the aspect, fired when it is a node, then every door node reached through `includes` and the nested
  # key `cuff`, each fired; a raw function where an aspect belongs is "<raw-function>"
  served =
    a:
    let
      walk =
        v:
        if isGuard v then
          let
            o = fire v;
          in
          (if o ? description then [ o.description ] else [ ]) ++ walk' o
        else if builtins.isFunction v then
          [ "<raw-function>" ]
        else if builtins.isAttrs v then
          walk' v
        else
          [ ];
      walk' = v: builtins.concatMap walk ((v.includes or [ ]) ++ (if v ? cuff then [ v.cuff ] else [ ]));
    in
    walk tree.config.aspects.${a};
in
{
  sleeveRegistrations = builtins.length (genRules.registrations tree.config.lambdas);
  sleeveServed = served "sleeve";
  sleeveControlServed = served "sleeveControl";
}
