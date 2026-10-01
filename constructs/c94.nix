# ── C94 — a rename of the frame of reference (den-hoag-41du, Landin 1966 §4) ──
#
# A key's category is what the key IS (ADR-0027 Ruling 2), so the identifier `nixos` is only a name
# for "a key of category `class`". A bijective rename ρ that keeps every category must then commute
# with projection: `project (ρ·values, ρ·cnf) = ρ·(project (values, cnf))`. The same ρ with the
# renamed key declared `channel` must NOT commute, or the comparison could not tell a term that kept
# its category from one that changed it.
#
# The universe is the corpus plus a SECOND class on `stitch`, `lampas`, spelled to sort between the
# rename target `fustian` and `nixos`. `attrNames` sorts, and ρ does not preserve that order, so a
# comparison of key LISTS reds on a correct `project` here; key sets are compared, sorted after ρ.
# Neither word occurs anywhere else in the corpus (ADR-0035).
#
# Projection only. The realization arm is not called here, for C6's reason: `realize` takes
# `terminals`, and the corpus would have to rebuild the hub's `terminalOf` bridge.
{ genDelivery, genValues }:
let
  from = "nixos";
  to = "fustian";
  second = "lampas";

  cnf = import ../aspect-cnf.nix;
  selectNodes = v: v.haberdashery or { };

  renameKey =
    a: b: s:
    if s ? ${a} then removeAttrs s [ a ] // { ${b} = s.${a}; } else s;

  # gen-delivery flattens nested aspects, so ρ descends into them. A sub-aspect is the child whose
  # `key` extends its parent's path; class and channel content is never descended into.
  rhoAspect =
    a:
    renameKey from to (
      builtins.mapAttrs (
        k: c: if builtins.isAttrs c && (c.key or null) == "${a.key}/${k}" then rhoAspect c else c
      ) a
    );
  # A kind value publishes its transitive ancestors as kind values under `__kindAncestors`; each
  # carries its own `keySemantics`, so ρ renames through the map as well.
  rhoKind =
    s:
    if s ? keySemantics then
      s
      // {
        keySemantics = renameKey from to s.keySemantics;
      }
      // (
        if s ? __kindAncestors then
          { __kindAncestors = builtins.mapAttrs (_: rhoKind) s.__kindAncestors; }
        else
          { }
      )
    else
      s;
  rho =
    v:
    v
    // {
      aspects = builtins.mapAttrs (_: rhoAspect) v.aspects;
      schema = builtins.mapAttrs (_: rhoKind) v.schema;
    };

  values = genValues // {
    aspects = genValues.aspects // {
      stitch = genValues.aspects.stitch // {
        ${second} = genValues.aspects.stitch.${from};
      };
    };
  };
  cnf2 = cnf // {
    keySemantics = cnf.keySemantics // {
      ${second}.category = "class";
    };
  };
  rhoCnf =
    category:
    cnf2
    // {
      keySemantics = removeAttrs cnf2.keySemantics [ from ] // {
        ${to} = { inherit category; };
      };
    };

  # Every attribute path in `v` whose last name is `name`. Stops at option types (`functor`), which
  # are cyclic, and at derivations; nothing else is skipped, and nothing is caught.
  pathsNamed =
    name: v:
    let
      walk =
        p: x:
        if !builtins.isAttrs x || x ? functor || x ? _type || (x.type or null) == "derivation" then
          [ ]
        else
          builtins.concatLists (
            map (k: (if k == name then [ (p ++ [ k ]) ] else [ ]) ++ walk (p ++ [ k ]) x.${k}) (
              builtins.attrNames x
            )
          );
    in
    map (builtins.concatStringsSep ".") (walk [ ] v);

  arm =
    v: c:
    genDelivery.project {
      values = v;
      cnf = c;
      inherit selectNodes;
    };
  identity = arm values cnf2;
  preserving = arm (rho values) (rhoCnf "class");
  changing = arm (rho values) (rhoCnf "channel");

  rhoName = k: if k == from then to else k;
  classSet =
    f: p:
    builtins.mapAttrs (
      _: n: builtins.sort builtins.lessThan (map f (builtins.attrNames n.classes))
    ) p.nodes;
  classContent = p: builtins.mapAttrs (_: n: builtins.toJSON (renameKey to from n.classes)) p.nodes;
in
{
  frameOfReferenceRename = {
    inherit from to second;
    # P6: ρ is complete — `from` names nothing in ρ·values — and the walk that says so can fire.
    residue = pathsNamed from (rho values);
    control = pathsNamed from values;
    identityClasses = classSet (k: k) identity;
    rhoIdentityClasses = classSet rhoName identity;
    preservingClasses = classSet (k: k) preserving;
    changingClasses = classSet (k: k) changing;
    # the preserving arm's classes renamed back, against identity's, as JSON
    preservingContent = classContent preserving;
    identityContent = classContent identity;
  };
}
