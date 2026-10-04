# `aspect-identity-inputs-read-only` -- den-hoag-qseuh. A declaration's identity is its origin and its
# declared path (identity design §1), so the two fields a caller can set to look like another declaration,
# `name` and `meta.aspect-chain`, are renderings and never inputs. The aspects are declared in the corpus's
# grammar and read through `key`, `aspectId` and `graphFacts`.
#   N-1 `plait` overrides its `name` to `warp`, another declaration's: it keeps its own key and id, and a
#       by-value include of it resolves to `plait`, not `warp`;
#   N-2 `selvage` sets `meta.aspect-chain` to `[ "hem" ]`, claiming `hem.selvage`'s chain: its identity is
#       refused by name, and the real `hem.selvage` is untouched (the property survives the refusal);
#   N-3 `hem.rib` sets the chain the type would stamp anyway, which is not a contradiction: it keys `hem/rib`;
#   N-4 a typed value included by value, and an alias at a tree position, keep the identity they carry
#       (the stamp rides with the value: the property the fix must not move);
#   N-5 `spool`, a guard declaring its own `name`, keeps its declared path;
#   N-6 two modules each write one named element into `loom.includes`: swapping the modules moves neither
#       element's key nor id (a named element is keyed by its declaring site under its owner, never by its
#       merge position; reordering includes changes nothing).
{
  asserts,
  genAspects,
  genMerge,
  lib,
}:
let
  # `closedKeys` off: `hem.selvage` is a nested aspect, which the corpus's closed vocabulary (C111) refuses
  cnf = import ../aspect-cnf.nix // {
    closedKeys = false;
    entityKinds = {
      loom = true;
    };
  };
  inherit (genAspects) guard pred;
  tree =
    body:
    (genMerge.evalModuleTree {
      modules = [
        { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
        body
      ];
    }).config.aspects;
  caught = x: !(builtins.tryEval (builtins.deepSeq x x)).success;
  id = genAspects.aspectId [ ];
  key = genAspects.key;

  n = tree (
    { config, ... }:
    {
      aspects = {
        plait = {
          name = "warp";
          nixos.marks = [ "plait" ];
        };
        warp.nixos.marks = [ "warp" ];
        bobbin.includes = [ config.aspects.plait ];
        spool = guard (pred.has "loom") {
          name = "warp";
          nixos.marks = [ "spool" ];
        };
      };
    }
  );
  nf = genAspects.graphFacts cnf n;
  n1 =
    key n.plait == "plait"
    && key n.warp == "warp"
    && id n.plait != id n.warp
    && nf.includesOf.bobbin == [ "plait" ]
    && n.plait.name == "warp";
  n5 = key n.spool != key n.warp && id n.spool != id n.warp;

  c = tree {
    aspects = {
      selvage = {
        meta.aspect-chain = [ "hem" ];
        nixos.marks = [ "selvage" ];
      };
      hem.selvage.nixos.marks = [ "hem-selvage" ];
      hem.rib = {
        meta.aspect-chain = [ "hem" ];
        nixos.marks = [ "rib" ];
      };
    };
  };
  n2 = caught (key c.selvage) && caught (id c.selvage) && key c.hem.selvage == "hem/selvage";
  n3 = key c.hem.rib == "hem/rib";

  v = tree (
    { config, ... }:
    {
      aspects = {
        base.nixos.marks = [ "base" ];
        user.includes = [ config.aspects.base ];
        lib.alias = config.aspects.base;
      };
    }
  );
  vf = genAspects.graphFacts cnf v;
  n4 = vf.includesOf.user == [ "base" ] && key v.lib.alias == "base" && id v.lib.alias == id v.base;

  heddle = {
    aspects.loom.includes = [
      {
        name = "heddle";
        description = "heddle";
      }
    ];
  };
  reed = {
    aspects.loom.includes = [
      {
        name = "reed";
        description = "reed";
      }
    ];
  };
  elems =
    mods:
    builtins.listToAttrs (
      map (e: {
        name = e.description;
        value = [
          (key e)
          (id e)
        ];
      }) (tree { imports = mods; }).loom.includes
    );
  hr = elems [
    heddle
    reed
  ];
  n6 =
    hr == elems [
      reed
      heddle
    ]
    && lib.hasPrefix "loom/includes/heddle@" (builtins.head hr.heddle);
in
{
  construct = [ "C182" ];
  check = asserts (n1 && n2 && n3 && n4 && n5 && n6);
}
