# ── C4b — element identity: a diamond is one element, a collision is two, and a key that
# splits an element refuses by name (ADR-0024 arm F, den-hoag-2vzn) ──
#
# ★★ ONE CELL CANNOT CARRY BOTH, MEASURED AT THE BINDING. `compositions.movement` fixes its
# key to a constant (`a: _: a.channel`), so a movement declaration reaches the one-group case
# only and cannot reach the spanning refusal at all. The spanning cell below is therefore
# built on `compositions.registry`, whose `entityOf` is caller-supplied.
#
# ★★★ TWO INDEPENDENT MASKERS REDUCE A DOUBLED DIAMOND TO ONE, AND THIS DECLARATION DEFEATS
# BOTH: an ASYMMETRIC admission (`tacks(gimping|tacks)*|gimping(tacks)*`, never the
# symmetric `(tacks|gimping)*` a caller might reach for, which folds both arrivals to one
# derivative-state class before the element check ever runs) and a `labelOrder` with BOTH
# letters in ONE layer (`endOfPath = -1`) — the exact shape `gen-view/ci/fixture.nix` ships
# as `flatOrder`. C4's own `movementCarrier` defeats neither: it declares a single-letter
# alphabet with `layers = [ [ "tacks" ] ]` and cannot carry this cell.
{ genView, identityMark }:
let
  diamondLabels = genView.edgeLabels {
    letters = [
      "tacks"
      "gimping"
    ];
  };
  diamondCarrier = genView.carrier {
    labels = diamondLabels;
    relations = genView.relations { names = [ "gimp" ]; };
    relatumLabels = genView.relatumLabels { names = [ ]; };
    labelWellFormedness = genView.labelWellFormedness {
      alphabet = diamondLabels;
      expression = "tacks(gimping|tacks)*|gimping(tacks)*";
    };
    labelOrder = genView.labelOrder {
      alphabet = diamondLabels;
      layers = [
        [
          "tacks"
          "gimping"
        ]
      ];
      endOfPath = -1;
    };
    dataOrder = genView.dataOrder {
      channel = "settled";
      keyOf = _: "settled";
    };
  };

  # `pewter` reaches `grosgrain` by two routes — one `tacks` hop, one `gimping` hop — leaving
  # DIFFERENT residual admission states; one `gimp` datum authored at `grosgrain`.
  diamondGraph = genView.scopeGraph {
    carrier = diamondCarrier;
    scopes = [
      "pewter"
      "grosgrain"
      "faille"
    ];
    edges = {
      tacks = id: if id == "pewter" then [ "grosgrain" ] else [ ];
      gimping = id: if id == "pewter" then [ "grosgrain" ] else [ ];
    };
    data = [
      {
        scope = "grosgrain";
        relation = "gimp";
        datum = [ "cambric" ];
      }
    ];
  };
  diamondMoved = genView.viewRelation {
    definition = genView.compositions.movement {
      channel = "selvage";
      relation = "gimp";
      root = "pewter";
      direction = "outbound";
      admission = diamondCarrier.labelWellFormedness;
      order = diamondCarrier.labelOrder;
      wellFormed = _: true;
      empty = [ ];
      tieSet = genView.tieSets.refuse;
      combine = genView.combines.listAppend;
      dedup = genView.dedups.none;
    };
    marks = _: [ ];
    orderMark = identityMark diamondLabels;
    graph = diamondGraph;
  };

  # The same datum content declared at `grosgrain` TWICE and at `faille` ONCE: three
  # declarations, one content. Element identity is `(producer, ordinal)` — the declaration
  # coordinate, never path-multiplicity — so three declarations mint three elements even
  # though every one of them carries the identical datum.
  collisionGraph = genView.scopeGraph {
    carrier = diamondCarrier;
    scopes = [
      "pewter"
      "grosgrain"
      "faille"
    ];
    edges = {
      tacks =
        id:
        if id == "pewter" then
          [
            "grosgrain"
            "faille"
          ]
        else
          [ ];
    };
    data = [
      {
        scope = "grosgrain";
        relation = "gimp";
        datum = [ "cambric" ];
      }
      {
        scope = "grosgrain";
        relation = "gimp";
        datum = [ "cambric" ];
      }
      {
        scope = "faille";
        relation = "gimp";
        datum = [ "cambric" ];
      }
    ];
  };
  collisionMoved = genView.viewRelation {
    definition = genView.compositions.movement {
      channel = "selvage";
      relation = "gimp";
      root = "pewter";
      direction = "outbound";
      admission = diamondCarrier.labelWellFormedness;
      order = diamondCarrier.labelOrder;
      wellFormed = _: true;
      empty = [ ];
      tieSet = genView.tieSets.union;
      combine = genView.combines.listAppend;
      dedup = genView.dedups.none;
    };
    marks = _: [ ];
    orderMark = identityMark diamondLabels;
    graph = collisionGraph;
  };

  # ── THE DEDUP DECIDES ON THE DECLARED RELATION, NEVER ON ITS ENCODING (den-hoag-behm0) ──
  # `dedups.byDatum` declares "structural equality on the datum itself", so SAME is Nix `==`.
  # Step 8 addresses its index by `builtins.toJSON`; deciding by that encoding instead records
  # a drop asserting a duplicate that does not exist, because `toJSON` serialises an
  # `outPath`/`__toString` attrset as its string coercion.
  #
  # Both declarations run on `collisionGraph`'s shape — three declarations under one `tacks`
  # hop each, whose multi-survivor property the `movement-element-identity` cell already
  # asserts live (`collisionMoved.contributions == 3` under `dedups.none`). Only the `dedup`
  # field and the authored data move between them.
  collisionDedupDefinition = genView.compositions.movement {
    channel = "selvage";
    relation = "gimp";
    root = "pewter";
    direction = "outbound";
    admission = diamondCarrier.labelWellFormedness;
    order = diamondCarrier.labelOrder;
    wellFormed = _: true;
    empty = [ ];
    tieSet = genView.tieSets.union;
    combine = genView.combines.listAppend;
    dedup = genView.dedups.byDatum;
  };
  collisionDedupOn =
    data:
    genView.viewRelation {
      definition = collisionDedupDefinition;
      marks = _: [ ];
      orderMark = identityMark diamondLabels;
      graph = genView.scopeGraph {
        carrier = diamondCarrier;
        scopes = [
          "pewter"
          "grosgrain"
          "faille"
        ];
        edges = {
          tacks =
            id:
            if id == "pewter" then
              [
                "grosgrain"
                "faille"
              ]
            else
              [ ];
        };
        inherit data;
      };
    };

  # THE REFERENCE — `collisionGraph`'s own three identical data under `byDatum`. A GENUINE
  # 3 → 1 collapse the declaration licenses, and it must keep happening: a build that
  # over-corrected into refusing all dedup would break this and leave the subject passing.
  collisionDeduped = collisionDedupOn collisionGraph.data;

  # THE SUBJECT — the same three declarations, differing in ONE TOKEN: `grosgrain`'s first
  # datum is wrapped as `{ outPath = "cambric"; }`. It is Nix-UNEQUAL to `[ "cambric" ]` and
  # encodes IDENTICALLY to it, so an encoding-decided dedup collapses all three and records
  # two drops of which one asserts a duplicate that does not exist. The declared relation
  # collapses only the two that really are equal: two survivors, ONE licensed drop.
  collisionCoerced = collisionDedupOn [
    {
      scope = "grosgrain";
      relation = "gimp";
      datum = [ { outPath = "cambric"; } ];
    }
    {
      scope = "grosgrain";
      relation = "gimp";
      datum = [ "cambric" ];
    }
    {
      scope = "faille";
      relation = "gimp";
      datum = [ "cambric" ];
    }
  ];

  # ── A FUNCTION-BEARING DATUM IS DEDUPED BY `==`, NEVER ABORTED ON (den-hoag-eunp3) ──
  # A NixOS module is a function. `cambricModule` is ONE binding authored at two scopes, so
  # Nix `==` calls the two `[ cambricModule ]` data equal; a second literal of the same text is
  # a second closure, which `==` calls distinct. Three declarations on `collisionGraph`'s
  # shape: two survivors, ONE licensed drop.
  cambricModule = { config, ... }: { };
  collisionModules = collisionDedupOn [
    {
      scope = "grosgrain";
      relation = "gimp";
      datum = [ cambricModule ];
    }
    {
      scope = "faille";
      relation = "gimp";
      datum = [ cambricModule ];
    }
    {
      scope = "faille";
      relation = "gimp";
      datum = [ ({ config, ... }: { }) ];
    }
  ];

  # THE ORACLE: every recorded drop is one the arm's own declared relation licenses. Read off
  # the RESULT alone — `definition` is carried inside `viewRelation`'s return — so it needs
  # nothing the caller did not already hand the call.
  noFalseDedup =
    r:
    builtins.all (
      d: r.definition.dedup.arm == "byDatum" -> d.contribution.datum == d.collapsedInto.datum
    ) r.dropped;

  # ★ THE ONLY DECLARATION IN THE CORPUS THAT REACHES THE SPANNING REFUSAL. `compositions.
  # registry`'s key is caller-supplied (`entityOf`); reading the DIAMOND's own residual
  # admission state makes the two arrivals of `diamondGraph`'s one authored element carry two
  # DIFFERENT keys, which is exactly what a competition key may never do.
  splitKeyed = genView.viewRelation {
    definition = genView.compositions.registry {
      channel = "selvage";
      relation = "gimp";
      root = "pewter";
      direction = "outbound";
      admission = diamondCarrier.labelWellFormedness;
      order = diamondCarrier.labelOrder;
      wellFormed = _: true;
      empty = [ ];
      tieSet = genView.tieSets.union;
      combine = genView.combines.listAppend;
      dedup = genView.dedups.none;
      entityOf = c: c.admission;
    };
    marks = _: [ ];
    orderMark = identityMark diamondLabels;
    graph = diamondGraph;
  };
in
{
  inherit
    diamondLabels
    diamondCarrier
    diamondGraph
    diamondMoved
    collisionGraph
    collisionMoved
    collisionDedupDefinition
    collisionDedupOn
    collisionDeduped
    collisionCoerced
    cambricModule
    collisionModules
    noFalseDedup
    splitKeyed
    ;
}
