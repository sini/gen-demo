# ── a guard carrier carried by value (gen-aspects + gen-rules; den-hoag-dmdou). Under C197's mounted cnf,
# `pocket` is a guard carrier: the closure `tuck`, a door node, beside a module function including the
# closure `hem`. `coat` includes `pocket`'s merged value. gen-aspects passes a carrier value through at
# an aspect position, re-stamped with that position, and gen-rules looks its closures up through the
# element's own view, so `coat` serves what `pocket` serves. Before, the carrier reached the guard-record
# arm, which read a `condition` a carrier does not have, and aborted uncatchably.
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
  tree = genMerge.evalModuleTree { } [
    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load "gen-demo:coat:tuck" { aspects.pocket = tuck; })
    (load "gen-demo:coat:hem" { aspects.pocket = { config, ... }: { includes = [ hem ]; }; })
    ({ config, ... }: { config.aspects.coat.includes = [ config.aspects.pocket ]; })
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
  # every door node reached through `includes`, fired, its description and its own includes'
  served =
    let
      walk =
        v:
        if isGuard v then
          let
            o = fire v;
          in
          (if o ? description then [ o.description ] else [ ]) ++ walk' o
        else if builtins.isAttrs v then
          walk' v
        else
          [ ];
      walk' = v: builtins.concatMap walk (v.includes or [ ]);
    in
    walk;
in
{
  carriedByValueRegistrations = builtins.length (genRules.registrations tree.config.lambdas);
  carriedByValueCoat = served tree.config.aspects.coat;
  carriedByValuePocket = served tree.config.aspects.pocket;
}
