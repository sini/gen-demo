# ── closed-pattern-and-functor-class-closures-are-lifted (den-hoag-iy9qh, den-hoag-ktnnu). Under the
# mounted cnf of `module-function-aspect-serves-its-closure`, four class-key closures over `bobbin` that
# gen-rules' loader once aborted on: a closed pattern (`{ bobbin }:`), a closed pattern naming a module
# argument (`{ bobbin, pkgs }:`), and a functor in the `setFunctionArgs` form and in the bare
# `__functor` form. Each lifts to a node guarded by `has bobbin` and is delivered at a context with
# `bobbin`, as its control, the open lambda `{ bobbin, ... }:`, is.
{
  genRules,
  genAlgebra,
  genAspects,
  genMerge,
  inputs,
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
    key = "gen-demo:closed-pattern-and-functor-class-closures-are-lifted";
    lambdasPath = [ "lambdas" ];
    aspectPaths = [ [ "aspects" ] ];
  };
  tree = genMerge.evalModuleTree { } [
    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load {
      aspects.closed.nixos = { bobbin }: { marker = "closed-${bobbin}"; };
      aspects.closedWithPkgs.nixos = { bobbin, pkgs }: { marker = "closedWithPkgs-${bobbin}-${pkgs}"; };
      aspects.functor.nixos = {
        __functionArgs = {
          bobbin = false;
          pkgs = false;
        };
        __functor = _: { bobbin, pkgs, ... }: { marker = "functor-${bobbin}-${pkgs}"; };
      };
      aspects.functorBare.nixos.__functor = _: { bobbin, ... }: { marker = "functorBare-${bobbin}"; };
      aspects.open.nixos = { bobbin, ... }: { marker = "open-${bobbin}"; };
    })
  ];
  inherit (tree.config) aspects lambdas;
  door = genRules.mkApply {
    inherit lambdas cnf;
    declared = D;
  };
  vocab = genAspects.mkGuardVocab (cnf // { ref = door; });
  inherit (inputs.gen.lib.substrate.identity) hashIdentity;
  T = genAlgebra.term hashIdentity;
  src = k: hashIdentity "entity" [ "name" ] (_: k);
  nodeOf =
    a:
    builtins.head (
      builtins.filter (x: builtins.isAttrs x && (x.__guard or false)) aspects.${a}.includes
    );
  context = {
    thimble = "pewter";
    bobbin = "spool";
  };
  # the delivered class value, read as its module system reads it
  marker =
    out:
    (genMerge.evalModuleTree { } [
      { options.marker = genMerge.mkOption { type = genMerge.types.str; }; }
      { config._module.args.pkgs = "loom"; }
      out.nixos
    ]).config.marker;
  lifted = a: {
    condition = (nodeOf a).condition;
    delivered = marker (
      vocab.applyGuardWith {
        inherit context;
        sources = builtins.mapAttrs (_: src) context;
        scope = { };
      } (nodeOf a)
    );
  };
in
{
  liftedShapes = builtins.listToAttrs (
    map (a: {
      name = a;
      value = lifted a;
    }) (builtins.attrNames aspects)
  );
  liftedShapesHasBobbin = T.term.all [ (T.term.has "bobbin") ];
}
