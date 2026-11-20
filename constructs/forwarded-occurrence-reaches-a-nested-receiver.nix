# ── forwarded-occurrence-reaches-a-nested-receiver (ADR-0028; gen-delivery `forward`, den-hoag-6md1q C5) ──
# Deliberately OUTSIDE `config.gen.composed`, the way C74 is: invented nodes and classes over the REAL
# `genDelivery.forward` and `genDelivery.realize`, `project → forward → realize`. The projections are written by hand
# (a cell's modules and the instance each belongs to, `occurrenceIds`), as `forward`'s lower-level resolved input.
#
# NESTED RECEIVER (spec G12): node `damask`'s occurrences, forwarded by `importsAt [ "spools" { dest = "name"; } ]`
# into node `pewter`'s attrsOf-submodule receiver (`shorthandOnlyDefinesConfig = true`, a `lines` and a `str`
# option), beside pewter's own content (`R`, spindle `receiver`).
#
# CONTAINED RECEIVER (spec G12's topology cell, invented): a `warp` holds `heddle`s, a heddle holds `pirn`s. Each
# pirn's own settings go to its heddle's cell at `pirns.<pirn>` (a declared item, the pirn's name read from its
# captured binding), and each heddle's WHOLE cell (declared plus received) is embedded in its warp at
# `heddles.<heddle>` (W1, the heddle's name read from the hop's scope). Two warps: `fringe` also receives a
# route declared twice, which refuses fringe by name while `selvage` stays usable. A second forward adds an empty
# warp `twill` whose one route carries a malformed `order`: heddle and pirn have no terminal, so their cells are
# stripped, and the sibling's fault reaches neither selvage nor the diagnostics.
{ genDelivery, lib }:
let
  inherit (lib) mkOption types mkDefault;
  route =
    {
      name,
      producer,
      order,
      class,
      node,
      select ? "declared",
      path,
    }:
    {
      inherit name producer order;
      site = "gen-demo:${producer}/${name}";
      from = { inherit class node select; };
      recipe.importsAt = path;
    };
  # cells: { <node>.<class> = [ [ <occurrence> <module> ] ]; }
  projectedOf = cells: {
    nodes = builtins.mapAttrs (n: per: {
      bindings.node.name = n;
      classes = builtins.mapAttrs (_: map (p: builtins.elemAt p 1)) per;
    }) cells;
    occurrenceIds = builtins.mapAttrs (_: builtins.mapAttrs (_: map builtins.head)) cells;
  };

  # ── the nested receiver ──
  spoolRecv = {
    options.spools = mkOption {
      type = types.attrsOf (
        types.submoduleWith {
          shorthandOnlyDefinesConfig = true;
          modules = [
            {
              options.thread = mkOption {
                type = types.lines;
                default = "";
              };
              options.spindle = mkOption {
                type = types.str;
                default = "unset";
              };
            }
          ];
        }
      );
      default = { };
    };
  };
  spoolTerminals = {
    weft =
      { modules, ... }:
      builtins.mapAttrs (_: s: { inherit (s) thread spindle; })
        (lib.evalModules { modules = [ spoolRecv ] ++ modules; }).config.spools;
    # damask's source class has a terminal that realizes nothing it is handed, so no content is stripped
    sett = _: null;
  };
  pewterOwn = {
    spools.pewter = {
      thread = "R";
      spindle = "receiver";
    };
  };
  mA = {
    thread = "A";
    spindle = mkDefault "group";
  };
  mA' = {
    thread = "A";
  };
  mB = {
    thread = "B";
  };
  toPewter =
    select:
    route {
      name = "to-pewter";
      producer = "damask";
      order = [ 0 ];
      class = "sett";
      node = "damask";
      inherit select;
      path = [
        "spools"
        { dest = "name"; }
      ];
    };
  nestedRun =
    damaskCell: routes:
    let
      f = genDelivery.forward { routes.weft.pewter = routes; } spoolTerminals (projectedOf {
        pewter.weft = [
          [
            "own"
            pewterOwn
          ]
        ];
        damask.sett = damaskCell;
      });
    in
    (genDelivery.realize { } spoolTerminals f.projected).weft.pewter
    // {
      check = f.check;
    };
  forwardNested = {
    # one occurrence, group [ mA mB ]
    oneOccurrence =
      nestedRun
        [
          [
            "o1"
            mA
          ]
          [
            "o1"
            mB
          ]
        ]
        [ (toPewter "declared") ];
    # two occurrences, declared o1 then o2
    twoOccurrences =
      nestedRun
        [
          [
            "o1"
            mA
          ]
          [
            "o2"
            mB
          ]
        ]
        [ (toPewter "declared") ];
    # equal content, distinct occurrences: both delivered
    equalContent =
      nestedRun
        [
          [
            "o1"
            mA
          ]
          [
            "o3"
            mA'
          ]
        ]
        [ (toPewter "declared") ];
    # the route carrying an undeclared key (a closure guard): refused by name, never delivered unconditionally
    guarded =
      nestedRun
        [
          [
            "o1"
            mA
          ]
        ]
        [ (toPewter "declared" // { guard = _: false; }) ];
    # the group forwarded alone (pewter's own spindle absent)
    alone =
      let
        f =
          genDelivery.forward { routes.weft.pewter = [ (toPewter "declared") ]; } spoolTerminals
            (projectedOf {
              pewter.weft = [
                [
                  "own"
                  { spools.pewter.thread = "R"; }
                ]
              ];
              damask.sett = [
                [
                  "o1"
                  mA
                ]
                [
                  "o1"
                  mB
                ]
              ];
            });
      in
      (genDelivery.realize { } spoolTerminals f.projected).weft.pewter;
  };

  # ── the contained receiver: warp > heddle > pirn ──
  warpRecv = {
    options.heddles = mkOption {
      type = types.attrsOf (
        types.submoduleWith {
          shorthandOnlyDefinesConfig = true;
          modules = [
            {
              options.reed = mkOption {
                type = types.int;
                default = 0;
              };
              options.pirns = mkOption {
                type = types.attrsOf (
                  types.submoduleWith {
                    shorthandOnlyDefinesConfig = true;
                    modules = [
                      {
                        options.ply = mkOption {
                          type = types.str;
                          default = "unset";
                        };
                      }
                    ];
                  }
                );
                default = { };
              };
            }
          ];
        }
      );
      default = { };
    };
  };
  warpTerminals = {
    warp = { modules, ... }: (lib.evalModules { modules = [ warpRecv ] ++ modules; }).config.heddles;
    # the heddle and pirn classes realize nowhere: their content travels only by route
  };
  heddleOf =
    heddle: pirns:
    map (
      p:
      route {
        name = "seat-${p}";
        producer = p;
        order = [ (lib.lists.findFirstIndex (x: x == p) 0 pirns) ];
        class = "pirn";
        node = p;
        path = [
          "pirns"
          {
            captured = "node";
            path = [ "name" ];
          }
        ];
      }
    ) pirns;
  embed =
    heddle: order:
    route {
      name = "embed-${heddle}";
      producer = heddle;
      inherit order;
      class = "heddle";
      node = heddle;
      select = "cell";
      path = [
        "heddles"
        {
          scope = "node";
          path = [ "name" ];
        }
      ];
    };
  containedCells = {
    selvage.warp = [ ];
    fringe.warp = [ ];
    tabby.heddle = [
      [
        "tabby"
        { reed = 12; }
      ]
    ];
    ottoman.heddle = [
      [
        "ottoman"
        { reed = 8; }
      ]
    ];
    quill.pirn = [
      [
        "quill"
        { ply = "two"; }
      ]
    ];
    cop.pirn = [
      [
        "cop"
        { ply = "three"; }
      ]
    ];
    spool.pirn = [
      [
        "spool"
        { ply = "single"; }
      ]
    ];
  };
  containedRoutes = {
    heddle.tabby = heddleOf "tabby" [
      "quill"
      "cop"
    ];
    heddle.ottoman = heddleOf "ottoman" [ "spool" ];
    warp.selvage = [
      (embed "tabby" [ 0 ])
      (embed "ottoman" [ 1 ])
    ];
    warp.fringe = [
      (embed "ottoman" [ 0 ])
      (embed "ottoman" [ 1 ])
    ];
  };
  containedOf =
    routes: cells:
    let
      f = genDelivery.forward { inherit routes; } warpTerminals (projectedOf cells);
    in
    {
      realized = genDelivery.realize { } warpTerminals f.projected;
      inherit (f) diagnostics;
    };
  forwardContained = containedOf containedRoutes containedCells;
  forwardContainedBesideMalformed = containedOf (
    containedRoutes
    // {
      warp = containedRoutes.warp // {
        twill = [ ((embed "tabby" [ 0 ]) // { order = "late"; }) ];
      };
    }
  ) (containedCells // { twill.warp = [ ]; });
in
{
  inherit forwardNested forwardContained forwardContainedBesideMalformed;
}
