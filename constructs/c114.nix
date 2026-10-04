# ── C114 — ADR-0029's four-tier value channel, end to end (den-hoag-zakjg U4) ──
#
# Contributor-local resolution, then structure. Each contributor is its OWN `evalModuleTree` of
# `x : str, default = "RD"`, its modules each carrying a `_file` naming it, so a winner's file names
# its contributor. gen-merge's `bandedLeaves` (U1) reads the band that contributor's own priority
# pass resolved `x` at: `force` < 100 ≤ `set` < 1000 ≤ `default` < 1500 ≤ unset, and an unset leaf
# moves nothing. A moved record is placed at the position of its band's head letter, and gen-view's
# `headPositions` (U2) builds the head layers of the order mark from the ranked letters, so the head
# letter decides first and structure only within one: `r` (the root, the host) is more specific than
# `t`, which it reaches on `tacks`. `joinedTrace` (U3, the J1 join; gen-view 47106a8) joins each
# surviving contribution back to the record of the evaluation it came from, and lists every record
# that did not move.
#
# THE RECEIVER (spec §8 U4, gate C2) is the evaluation at the node the movement lands on, whose
# definitions of `x` are exactly the moved list, seeded by its own declared default. The host
# contributes through its position only; its own evaluation taken as the receiver is the red arm.
#
# The band → head-letter map is the caller's (Q4 (i)), and here it is the identity, written as a
# table so a placement reading the wrong band is visible against it.
{
  genMerge,
  genView,
  genScope,
}:
let
  gm = genMerge;
  v = genView;
  heads = [
    "force"
    "set"
    "default"
  ];
  headOf = {
    force = "force";
    set = "set";
    default = "default";
  };
  optDecl = {
    options.x = gm.mkOption {
      type = gm.types.str;
      default = "RD";
    };
  };
  modulesOf =
    scope: defs:
    map (d: {
      _file = "${scope}.nix";
      config.x = d;
    }) defs;
  evalOf = scope: defs: gm.evalModuleTree { modules = [ optDecl ] ++ modulesOf scope defs; };
  receiverOf =
    moved: (gm.evalModuleTree { modules = [ optDecl ] ++ map (d: { config.x = d; }) moved; }).config.x;

  structure =
    {
      scopes,
      edges,
      expression,
      endOfPath,
    }:
    let
      labels = v.edgeLabels { letters = [ "tacks" ]; };
    in
    v.scopeGraph {
      carrier = v.carrier {
        inherit labels;
        relations = v.relations { names = [ "tier" ]; };
        relatumLabels = v.relatumLabels { names = [ ]; };
        labelWellFormedness = genScope.wellFormed {
          alphabet = labels.letters;
          inherit expression;
        };
        # `$` below `tacks`: the root's own shorter word beats one continuing, "most specific
        # wins". `endOfPath = 1` is the control where continuing beats stopping.
        labelOrder = genScope.labelOrder {
          alphabet = labels.letters;
          layers = [ [ "tacks" ] ];
          inherit endOfPath;
        };
        dataOrder = v.dataOrder {
          channel = "selvage";
          keyOf = _: "selvage";
        };
      };
      inherit scopes edges;
      data = [ ];
    };

  # One field moved across one structure. `contributions` maps each scope to its definitions of
  # `x`; `evals` replaces a scope's evaluation outright. `pairing s` names the scope whose
  # evaluation is stamped with `s`'s scope id (the identity, unless a cell mis-pairs them).
  channel =
    {
      contributions,
      evals ? { },
      pairing ? s: s,
      edges ? {
        tacks =
          id: if id == "r" then builtins.filter (s: s != "r") (builtins.attrNames contributions) else [ ];
      },
      expression ? "tacks?",
      endOfPath ? -1,
      tieSet ? _: v.tieSets.union,
      wellFormed ? _: true,
      marks ? _: _: [ ],
      headFor ? r: headOf.${r.band},
      innerOf ? records: s: records.${s},
    }:
    let
      scopes = builtins.attrNames contributions;
      records = builtins.listToAttrs (
        map (s: {
          name = s;
          value =
            (gm.bandedLeaves {
              scope = s;
              result = evals.${pairing s} or (evalOf (pairing s) contributions.${pairing s});
            }).x;
        }) scopes
      );
      pos = v.headPositions {
        engine = genScope;
        inherit heads;
        structure = structure {
          inherit
            scopes
            edges
            expression
            endOfPath
            ;
        };
        root = "r";
        data = builtins.concatMap (
          r:
          if r ? band then
            [
              {
                inherit (r) scope;
                head = headFor r;
                relation = "tier";
                datum = [ r.value ];
              }
            ]
          else
            [ ]
        ) (builtins.attrValues records);
      };
      relation = v.viewRelation {
        engine = genScope;
        definition = v.compositions.movement {
          channel = "selvage";
          relation = "tier";
          inherit (pos) root admission order;
          inherit wellFormed;
          direction = "outbound";
          empty = [ ];
          tieSet = tieSet pos;
          combine = v.combines.listAppend;
          dedup = v.dedups.none;
        };
        marks = marks pos;
        inherit (pos) orderMark graph;
      };
      joined = v.joinedTrace {
        inherit relation;
        placement = {
          mode = "merge";
          path = [ ];
        };
        positions = pos;
        innerOf = innerOf records;
      };
    in
    {
      inherit records joined;
      moved = relation.value;
      received = receiverOf relation.value;
      # the red arm of the receiver: the host's own evaluation, given the moved list as well
      receivedByHost = receiverOf ((contributions.r or [ ]) ++ relation.value);
      ownFiles = s: map (m: m._file) (modulesOf s contributions.${s});
    };

  cases = {
    k1 = {
      r = [ "R" ];
      t = [ "T" ];
    };
    k2 = {
      r = [ (gm.mkDefault "RD") ];
      t = [ "T" ];
    };
    k3 = {
      r = [ ];
      t = [ (gm.mkDefault "TD") ];
    };
    k4 = {
      r = [ "R" ];
      t = [ (gm.mkForce "TF") ];
    };
    k5 = {
      r = [ (gm.mkOptionDefault "RO") ];
      t = [ ];
    };
    k6 = {
      r = [ ];
      t = [ ];
    };
  };

  # The root's evaluation under each of U1's reasons for moving nothing, the default-only one
  # aside (k3, k5 and k6 carry it): `x` declared with no default and defined by nobody, and `x`
  # undeclared, so a definition of it lands on the freeform plane, which has no priority pass.
  unsetEvals = {
    noDefinition = gm.evalModuleTree {
      modules = [
        {
          _file = "r.nix";
          options.x = gm.mkOption { type = gm.types.str; };
        }
      ];
    };
    freeform = gm.evalModuleTree {
      modules = [
        {
          _file = "r.nix";
          freeformType = gm.types.attrsOf gm.types.str;
        }
        {
          _file = "r.nix";
          x = "R";
        }
      ];
    };
  };
in
{
  fourTier = {
    inherit
      headOf
      cases
      channel
      unsetEvals
      ;
    case = k: args: channel ({ contributions = cases.${k}; } // args);
  };
}
