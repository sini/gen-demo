# ── C198 — a closure that returns a module function (gen-rules door; den-hoag-zm0gu). Under C197's
# mounted cnf, two load-time closures over `thimble` return a module function. The module system applies
# it downstream, under arguments the door never holds, so the door checks its result when applied:
# `plain`'s result holds no closure and is served, and `stitched`'s writes a class closure over `bobbin`,
# which can be neither registered nor scoped and is refused by name at its position (row 155), where it
# was delivered without its `has bobbin` guard.
{
  genRules,
  genAspects,
  genMerge,
}:
let
  D = [
    "thimble"
    "bobbin"
  ];
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
    key = "gen-demo:c198";
    lambdasPath = [ "lambdas" ];
    aspectPaths = [ [ "aspects" ] ];
  };
  schema = genAspects.mkAspectSchema cnf;
  tree = genMerge.evalModuleTree { } [
    { options.aspects = schema.mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load {
      aspects.plain.includes = [
        (
          { thimble, ... }:
          { config, ... }:
          {
            nixos = { pkgs, ... }: { marker = "plain-${thimble}-${pkgs}"; };
          }
        )
      ];
      aspects.stitched.includes = [
        (
          { thimble, ... }:
          { config, ... }:
          {
            nixos = { bobbin, pkgs, ... }: { marker = "stitched-${bobbin}"; };
          }
        )
      ];
    })
  ];
  inherit (tree.config) aspects lambdas;
  door = genRules.mkApply {
    inherit lambdas cnf;
    declared = D;
  };
  vocab = genAspects.mkGuardVocab (cnf // { ref = door; });
  isGuard = x: builtins.isAttrs x && (x.__guard or false);
  # the door's output at `thimble = "pewter"`, received downstream as an aspect definition
  received =
    a:
    (genMerge.evalModuleTree { } [
      { options.aspects = schema.mkAspectOption { }; }
      {
        aspects.probe = vocab.applyGuardWith {
          context.thimble = "pewter";
          sources = { };
          scope = { };
        } (builtins.head (builtins.filter isGuard aspects.${a}.includes));
      }
    ]).config.aspects.probe;
  marker =
    m:
    (genMerge.evalModuleTree { } [
      { options.marker = genMerge.mkOption { type = genMerge.types.str; }; }
      { config._module.args.pkgs = "P"; }
      m
    ]).config.marker;
  # forcing the received aspect's `includes` forces the closure's position
  stitched = builtins.deepSeq (map isGuard (received "stitched").includes) "delivered";
in
{
  c198Plain = marker (received "plain").nixos;
  c198Stitched = stitched;
  c198StitchedRefused = !(builtins.tryEval stitched).success;
}
