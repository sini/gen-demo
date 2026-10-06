# ── C201 — a closure under a property wrapper is lowered as the same closure unwrapped (gen-rules;
# den-hoag-crk5e). Under C197's mounted cnf, the conditional shapes a consumer writes: `hem` holds its
# closure over `thimble` in `includes = mkIf true [ … ]`, a module writes `pleat`'s under
# `config = mkIf true { … }`, and `seam` writes a class closure over `bobbin` as `nixos = mkIf true …`.
# Each is lowered to the door node its unwrapped control is (`hemControl`, `pleatControl`,
# `seamControl`). At the class key the `mkIf` rides on the class value inside the lifted node, so
# `seamOff`'s `mkIf false` registers and fires and delivers nothing. Before, `hem` and `pleat` were
# refused by gen-aspects' bare-closure refusal, and `seam` was delivered with its guard dropped.
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
  load =
    key:
    genRules.defunctionalize {
      inherit cnf key;
      declared = D;
      lambdasPath = [ "lambdas" ];
      aspectPaths = [ [ "aspects" ] ];
    };
  inherit (genMerge) mkIf;
  hemClosure = { thimble, ... }: { description = "hem-${thimble}"; };
  pleatClosure = { thimble, ... }: { description = "pleat-${thimble}"; };
  seamClosure = { bobbin, pkgs, ... }: { marker = "seam-${bobbin}"; };
  schema = genAspects.mkAspectSchema cnf;
  tree = genMerge.evalModuleTree { } [
    { options.aspects = schema.mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load "gen-demo:c201" {
      aspects.hem.includes = mkIf true [ hemClosure ];
      aspects.hemControl.includes = [ hemClosure ];
      aspects.pleatControl.includes = [ pleatClosure ];
      aspects.seam.nixos = mkIf true seamClosure;
      aspects.seamControl.nixos = seamClosure;
      aspects.seamOff.nixos = mkIf false seamClosure;
    })
    (load "gen-demo:c201-config" { config = mkIf true { aspects.pleat.includes = [ pleatClosure ]; }; })
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
  # the door's output received downstream as an aspect definition, so its class value is read as the
  # class option reads it (a class-key `mkIf` is discharged there); `none` when it delivers nothing
  delivered =
    a:
    let
      nixos =
        (genMerge.evalModuleTree { } [
          { options.aspects = schema.mkAspectOption { }; }
          {
            aspects.probe = fire {
              thimble = "pewter";
              bobbin = "spool";
            } a;
          }
        ]).config.aspects.probe.nixos;
    in
    {
      condition = (nodeOf a).condition;
      atSpool =
        if nixos == null then
          "none"
        else
          (genMerge.evalModuleTree { } [
            { options.marker = genMerge.mkOption { type = genMerge.types.str; }; }
            { config._module.args.pkgs = "P"; }
            nixos
          ]).config.marker;
    };
in
{
  c201Registrations = builtins.length (genRules.registrations lambdas);
  c201Hem = per "hem";
  c201HemControl = per "hemControl";
  c201Pleat = per "pleat";
  c201PleatControl = per "pleatControl";
  c201Seam = delivered "seam";
  c201SeamControl = delivered "seamControl";
  c201SeamOff = delivered "seamOff";
  c201HasThimble = T.term.all [ (T.term.has "thimble") ];
  c201HasBobbin = T.term.all [ (T.term.has "bobbin") ];
}
