# `aspect-identity-structured-key` -- den-hoag-gywcg. An aspect's identity is its declaring position as a
# structured value (identity design §1), so no rendering of it can join two declarations, and the type is
# the one writer of the identity inputs (ADR-0016 r5, one minting authority). Read through `key`,
# `aspectId` and `graphFacts`.
#   K-1 `"warp/weft"` beside `warp.weft`: two keys, two ids, two vertices (static and guard alike);
#   K-2 two elements of `loom.includes` both named `heddle`, at two positions: two keys and two ids, and
#       swapping the two modules that write `shuttle.includes` moves neither (the declaring position,
#       never the merged one);
#   K-2b K-2's shape one level down: a `pirn` named inside an unnamed `shuttle.includes` element, written
#       by two keyed modules, read in both orders and behind a module writing an empty `includes` first.
#       Neither id moves, and each key extends its enclosing element's key (the enclosing element's
#       declared position, never its merge one);
#   K-3 one caller write of `meta.loc`, `key` or `id_hash` is refused where it is read, and a `meta.loc`
#       written at `mkForce` is refused at `key` and at `aspectId` alike; a write equal to the type's own
#       value mints nothing and is accepted; the untouched `bobbin` keys as declared (the refusal is the
#       write's, not the tree's);
#   K-4 a typed value included by value, and an alias at a tree position, keep the identity they carry;
#   K-5 a named `includes` element writing `key`, `id_hash` or `meta.loc` is refused, where the element's
#       module reading would drop a `key` silently; the unwritten element keeps its content.
{
  asserts,
  genAspects,
  genMerge,
  lib,
}:
let
  cnf = import ../aspect-cnf.nix // {
    closedKeys = false;
  };
  inherit (genAspects) guard pred;
  tree =
    body:
    (genMerge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      body
    ]).config.aspects;
  caught = x: !(builtins.tryEval (builtins.deepSeq x x)).success;
  id = genAspects.aspectId [ ];
  key = genAspects.key;
  apart = a: b: key a != key b && id a != id b;

  s = tree {
    aspects = {
      "warp/weft".nixos.marks = [ "slash" ];
      warp.weft.nixos.marks = [ "nested" ];
      "reed/dent" = guard (pred.has "loom") { nixos.marks = [ "slash" ]; };
      reed.dent = guard (pred.has "loom") { nixos.marks = [ "nested" ]; };
    };
  };
  k1 =
    apart s."warp/weft" s.warp.weft
    && apart s."reed/dent" s.reed.dent
    && builtins.length (builtins.attrNames (genAspects.graphFacts cnf s).nodeData) == 6;

  one = tree {
    aspects.loom.includes = [
      {
        name = "heddle";
        description = "first";
      }
      {
        name = "heddle";
        description = "second";
      }
    ];
  };
  front = {
    aspects.shuttle.includes = [
      {
        name = "pirn";
        description = "front";
      }
    ];
  };
  back = {
    aspects.shuttle.includes = [
      {
        name = "pirn";
        description = "back";
      }
    ];
  };
  byDescription =
    mods:
    builtins.listToAttrs (
      map (e: {
        name = e.description;
        value = id e;
      }) (tree { imports = mods; }).shuttle.includes
    );
  fb = byDescription [
    front
    back
  ];
  nested = desc: {
    key = "nested-${desc}";
    aspects.shuttle.includes = [
      {
        description = "outer-${desc}";
        includes = [
          {
            name = "pirn";
            description = desc;
          }
        ];
      }
    ];
  };
  empty = {
    key = "empty";
    aspects.shuttle.includes = [ ];
  };
  below =
    mods:
    builtins.listToAttrs (
      map (
        e:
        let
          c = builtins.head e.includes;
        in
        {
          name = c.description;
          value = {
            id = id c;
            extends = lib.hasPrefix (key e + "/includes/") (key c);
          };
        }
      ) (tree { imports = mods; }).shuttle.includes
    );
  nb = below [
    (nested "front")
    (nested "back")
  ];
  k2b =
    nb.front.id != nb.back.id
    && nb.front.extends
    && nb.back.extends
    &&
      nb == below [
        (nested "back")
        (nested "front")
      ]
    &&
      nb == below [
        empty
        (nested "front")
        (nested "back")
      ];
  k2 =
    apart (builtins.elemAt one.loom.includes 0) (builtins.elemAt one.loom.includes 1)
    && fb.front != fb.back
    &&
      fb == byDescription [
        back
        front
      ];

  w =
    write:
    tree {
      aspects = {
        selvage = write;
        bobbin.nixos.marks = [ "bobbin" ];
      };
    };
  forced = w { meta.loc = genMerge.mkForce [ "bobbin" ]; };
  k3 =
    caught (key (w { meta.loc = [ "bobbin" ]; }).selvage)
    && caught (w { key = "bobbin"; }).selvage.key
    && caught (w { id_hash = "aspect:0"; }).selvage.id_hash
    && caught (key forced.selvage)
    && caught (id forced.selvage)
    && caught (w { key = genMerge.mkForce "bobbin"; }).selvage.key
    && (w { key = "selvage"; }).selvage.key == "selvage"
    && key (w { meta.loc = [ "bobbin" ]; }).bobbin == "bobbin";

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
  k4 =
    (genAspects.graphFacts cnf v).includesOf.user == [ "base" ]
    && key v.lib.alias == "base"
    && id v.lib.alias == id v.base;

  el =
    write:
    builtins.head
      (tree {
        aspects.loom.includes = [
          (
            {
              name = "heddle";
              nixos.marks = [ "heddle" ];
            }
            // write
          )
        ];
      }).loom.includes;
  k5 =
    caught (el { key = "bobbin"; }).key
    && caught (el { id_hash = "aspect:0"; }).id_hash
    && caught (
      key (el {
        meta.loc = [ "bobbin" ];
      })
    )
    && (el { }).nixos != null
    && lib.hasPrefix "loom/includes/heddle@" (el { }).key;
in
{
  construct = [ "aspects-identity-is-its-declaring-position-structured" ];
  check = asserts (k1 && k2 && k2b && k3 && k4 && k5);
  limbs = {
    inherit
      k1
      k2
      k2b
      k3
      k4
      k5
      ;
  };
}
