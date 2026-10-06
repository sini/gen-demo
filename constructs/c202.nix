# ── C202 — a class closure a door's output writes is lifted and fires (gen-rules door; den-hoag-p5k3k).
# Under C197's mounted cnf, a load-time closure over `thimble` returns an attrset output that writes a
# class closure over `bobbin` at `nixos`: `seam` with a module arg (`pkgs`), `tack` over the coordinate
# only, and `hem` beside its own nested closure in a wrapped `includes = mkIf true [ … ]`. The door
# lowers its output with the same walk as the loader, so each class closure is lifted into a nested door
# node in `includes`, and gen-aspects fires it at the address the door's scope names. Fired at
# `thimble = "pewter"`, `bobbin = "spool"`, each delivers its class value; `hem`'s nested closure
# delivers beside it. Before, every one was refused by gen-aspects' door-result-shape check: the scope
# named the class key the closure was written at, which holds no guard in the output.
{
  genRules,
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
    key = "gen-demo:c202";
    lambdasPath = [ "lambdas" ];
    aspectPaths = [ [ "aspects" ] ];
  };
  schema = genAspects.mkAspectSchema cnf;
  tree = genMerge.evalModuleTree { } [
    { options.aspects = schema.mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load {
      aspects.seam.includes = [
        ({ thimble, ... }: {
          nixos = { bobbin, pkgs, ... }: { marker = "seam-${thimble}-${bobbin}-${pkgs}"; };
        })
      ];
      aspects.tack.includes = [
        ({ thimble, ... }: { nixos = { bobbin, ... }: { marker = "tack-${bobbin}"; }; })
      ];
      aspects.hem.includes = [
        (
          { thimble, ... }:
          {
            includes = genMerge.mkIf true [ ({ bobbin, ... }: { description = "hem-${bobbin}"; }) ];
            nixos = { bobbin, pkgs, ... }: { marker = "hem-class-${bobbin}"; };
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
  inherit (inputs.gen.lib.substrate.identity) hashIdentity;
  src = k: hashIdentity "entity" [ "name" ] (_: k);
  context = {
    thimble = "pewter";
    bobbin = "spool";
  };
  # the outer's firing, its nested nodes fired in place by gen-aspects (the lexically nested path)
  fired =
    a:
    vocab.applyGuardWith {
      inherit context;
      sources = builtins.mapAttrs (_: src) context;
      scope = { };
    } (builtins.head (builtins.filter (x: x.__guard or false) aspects.${a}.includes));
  # the fired output received downstream as an aspect definition, as C201 reads it: each `includes`
  # element's class marker, or its description
  delivered =
    a:
    let
      probe =
        (genMerge.evalModuleTree { } [
          { options.aspects = schema.mkAspectOption { }; }
          { aspects.probe = fired a; }
        ]).config.aspects.probe;
      marker =
        m:
        (genMerge.evalModuleTree { } [
          { options.marker = genMerge.mkOption { type = genMerge.types.str; }; }
          { config._module.args.pkgs = "P"; }
          m
        ]).config.marker;
    in
    map (x: if x.nixos != null then marker x.nixos else x.description) probe.includes;
in
{
  c202Seam = delivered "seam";
  c202Tack = delivered "tack";
  c202Hem = delivered "hem";
}
