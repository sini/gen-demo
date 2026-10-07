# `options-first-composes-link-delivery` — C91, den-hoag-7gp66 P2 L6. The same law as
# `options-first-composes`, at gen-link and gen-delivery. `federate` is gen-link's `link` with its
# `wire` option stated once, then applied to C11's mill and loom sources in both orders, the
# subject, last: each binds `loom/braid`, where the same door under `{ }` refuses the unwired hole.
# `stampAt` is `originStamp { } [ "bolt" ]` mapped over the two normalized registries: every node it
# stamps is named under `bolt`. `row` is `entry { via; }`, its record step applied to two edges.
# `projectBobbins` is gen-delivery's `project` with its `selectNodes` option stated once and its
# `cnf` supplied, mapped over two value sets: under `{ }` the same door has no node selector and its
# nodes are refused. Each door's contract is read AS DATA (`__contract`, `entry`'s record step under
# `next`), and five refusals are caught at the step they belong to: an unknown option, the
# unmigrated one-record `link { sources; }`, `project { values; cnf; }` and `realize { projected;
# terminals; }` (none of those fields is an option), and `via` given on `entry`'s record rather
# than its options.
{
  asserts,
  genDelivery,
  genLink,
  genValues,
  loom,
  mill,
  selvageFacets,
}:
let
  src = origin: reg: {
    registry = reg.config.aspects;
    keySemantics = selvageFacets;
    inherit origin;
  };
  millSrc = src [ "mill" ] mill;
  loomSrc = src [ "loom" ] loom;

  federate = genLink.link { wire."loom/braid".selvageReq = "mill/stitch"; };
  boundIn = sources: map (b: b.identifier) (federate sources).bound;

  stampAt = genLink.originStamp { } [ "bolt" ];

  row = genLink.entry { via = "selvageReq"; };
  edge = from: to: {
    kind = "hole";
    inherit from to;
    fromKind = "aspect";
    toKind = "aspect";
  };

  cnf = import ../aspect-cnf.nix;
  projectBobbins = genDelivery.project { selectNodes = v: v.bobbins or { }; } cnf;

  refuses = e: !(builtins.tryEval (builtins.seq e null)).success;
  answers = e: (builtins.tryEval (builtins.deepSeq e null)).success;
in
{
  construct = [ "doors-options-first-and-composed" ];
  check = asserts (
    map boundIn [
      [
        millSrc
        loomSrc
      ]
      [
        loomSrc
        millSrc
      ]
    ] == [
      [ "loom/braid" ]
      [ "loom/braid" ]
    ]
    # control: the same door under `{ }` leaves the hole unwired, and the call refuses it
    && !answers
      (genLink.link { } [
        millSrc
        loomSrc
      ]).bound
    &&
      map
        (
          r:
          builtins.all (v: builtins.substring 0 5 v == "bolt/") (
            builtins.attrNames (stampAt (genLink.normalize r.config.aspects)).idToNode
          )
        )
        [
          mill
          loom
        ] == [
        true
        true
      ]
    &&
      map (e: (row e).via) [
        (edge "loom/braid" "mill/stitch")
        (edge "loom/hem" "mill/stitch")
      ] == [
        "selvageReq"
        "selvageReq"
      ]
    &&
      map (v: builtins.length (builtins.attrNames (projectBobbins v).nodes)) [
        genValues
        { }
      ] == [
        (builtins.length (
          builtins.attrNames (genDelivery.project { selectNodes = v: v.bobbins or { }; } cnf genValues).nodes
        ))
        0
      ]
    && (projectBobbins genValues).nodes != { }
    # control: under `{ }` there is no node selector, and reading the nodes refuses by name
    && !answers (genDelivery.project { } cnf genValues).nodes
    && genLink.link.__contract.optional == [ "wire" ]
    &&
      genLink.entry.__contract.next.required == [
        "kind"
        "from"
        "fromKind"
        "to"
        "toKind"
      ]
    &&
      genDelivery.realize.__contract.optional == [
        "bindings"
        "refinements"
        "layerOrder"
        "extraModules"
      ]
    && refuses (genLink.originStamp { aliases = { }; })
    && refuses (genLink.link { sources = [ millSrc ]; })
    && refuses (
      genDelivery.project {
        values = genValues;
        inherit cnf;
      }
    )
    && refuses (
      genDelivery.realize {
        projected = projectBobbins genValues;
        terminals = { };
      }
    )
    && refuses (genLink.entry { } (edge "loom/braid" "mill/stitch" // { via = "selvageReq"; }))
    # control: the same predicate admits a well-formed options application
    && !refuses (genLink.link { })
  );
}
