# ── C203 — a module function written beside a closure at one aspect key (gen-rules + gen-aspects;
# den-hoag-cgobz). Under C197's mounted cnf, two modules define `pocket`: one writes the closure
# `{ thimble, ... }: …`, which gen-rules lowers into a door node, and the other a module function whose
# result holds a closure over `thimble`. The door node makes `pocket` a guard carrier, and gen-aspects
# applies the module function once, in its own `includes` element, held in a coerced fragment (F4(b)),
# where the root reaches its table. Both closures are registered and both fire, as `pocketControl`
# does, where the second module writes its closure plainly. Before, the module function's closure was
# registered in no table the root reaches, so one of the two was served.
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
    (load "gen-demo:c203:tuck" {
      aspects.pocket = tuck;
      aspects.pocketControl = tuck;
    })
    (load "gen-demo:c203:hem" {
      aspects.pocket = { config, ... }: { includes = [ hem ]; };
      aspects.pocketControl.includes = [ hem ];
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
  # the carrier fired, then every door node its output holds, descending into include elements
  served =
    a:
    let
      o = fire tree.config.aspects.${a};
      nodes =
        v:
        builtins.concatMap (
          e:
          if isGuard e then
            [ e ]
          else if builtins.isAttrs e then
            nodes e
          else
            [ ]
        ) (v.includes or [ ]);
    in
    [ o.description ] ++ map (n: (fire n).description) (nodes o);
in
{
  c203Registrations = builtins.length (genRules.registrations tree.config.lambdas);
  c203Pocket = served "pocket";
  c203PocketControl = served "pocketControl";
}
