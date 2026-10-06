# ── C197 — a module-function aspect serves its closure (gen-rules S1 arm (a); den-hoag-lwbb1). The
# framework mounts gen-rules' registration table inside gen-aspects' aspect submodule (`lambdasMount` in
# `cnf.aspectModules`), and hands that one cnf to the schema, the loader and the door. Two aspects are
# written as module functions: `hem` holds a closure over `thimble` in `includes`, and `seam` a closure
# over `bobbin` at the class key `nixos`. Each closure registers when gen-merge applies its function,
# and is lowered to a door node like the same text written outside the function (`hemControl`,
# `seamControl`). No union module is written: gen-rules' loader ships it. `seamCoordinateOnly` writes its
# class closure over the coordinate alone (`{ bobbin, ... }`); its lift is a class value the door admits
# whatever formals remain (den-hoag-d13lv), so it is delivered at a context with `bobbin`, as its control
# is.
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
    # read raw by gen-rules' walk at a class key, so it is declared here
    moduleArgs = {
      config = true;
      pkgs = true;
    };
    aspectModules = [ (genRules.lambdasMount "lambdas") ];
  };
  load = genRules.defunctionalize {
    inherit cnf;
    declared = D;
    key = "gen-demo:c197";
    lambdasPath = [ "lambdas" ];
    aspectPaths = [ [ "aspects" ] ];
  };
  hemBody = {
    description = "hem";
    includes = [ ({ thimble, ... }: { description = "hem-${thimble}"; }) ];
  };
  seamBody = {
    nixos = { bobbin, pkgs, ... }: { };
  };
  seamCoordinateOnlyBody = {
    nixos = { bobbin, ... }: { marker = "seam-${bobbin}"; };
  };
  tree = genMerge.evalModuleTree { } [
    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load {
      aspects.hem = { config, ... }: hemBody;
      aspects.seam = { config, ... }: seamBody;
      aspects.hemControl = hemBody;
      aspects.seamControl = seamBody;
      aspects.seamCoordinateOnly = { config, ... }: seamCoordinateOnlyBody;
      aspects.seamCoordinateOnlyControl = seamCoordinateOnlyBody;
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
  # the door node an aspect's closure was lowered to (the first guard in its `includes`)
  nodeOf =
    a:
    builtins.head (
      builtins.filter (x: builtins.isAttrs x && (x.__guard or false)) aspects.${a}.includes
    );
  fire =
    context: a:
    vocab.applyGuardWith {
      inherit context;
      sources = builtins.mapAttrs (_: src) context;
      scope = { };
    } (nodeOf a);
  per = a: {
    condition = (nodeOf a).condition;
    atPewter = fire { thimble = "pewter"; } a;
  };
  # the delivered class value, read as its module system reads it
  marker =
    out:
    (genMerge.evalModuleTree { } [
      { options.marker = genMerge.mkOption { type = genMerge.types.str; }; }
      out.nixos
    ]).config.marker;
  perDelivered = a: {
    condition = (nodeOf a).condition;
    atSpool = marker (
      fire {
        thimble = "pewter";
        bobbin = "spool";
      } a
    );
  };
in
{
  c197Registrations = builtins.length (genRules.registrations lambdas);
  c197Hem = per "hem";
  c197HemControl = per "hemControl";
  c197Seam = per "seam";
  c197SeamControl = per "seamControl";
  c197SeamCoordinateOnly = perDelivered "seamCoordinateOnly";
  c197SeamCoordinateOnlyControl = perDelivered "seamCoordinateOnlyControl";
  c197HasBobbin = T.term.all [ (T.term.has "bobbin") ];
}
