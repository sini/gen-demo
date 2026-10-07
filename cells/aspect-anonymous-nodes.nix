# `anonymous-declarations-are-nodes` — aspect-anonymous-nodes, den-hoag-8hlo3. Inline content is a
# node keyed by its declaration: `yoke`'s literal, the literal nested in it, and the let-bound `shared`
# at `yoke` and at `cuff` (two nodes); `welt`'s edited copy of `placard`'s literal, re-declared at
# `welt`; and `gore`'s applied-body literal once per instance. `elementIds` names each at its slot;
# the named `piping` stays a position (`null`, unresolved at its literal). What each host receives
# equals the previous pin's. The two path modules give `seam` the same ids in both orders, asserted
# by their structure, never by a literal id: a path module's anchor is its store path, which moves
# with the corpus source. Red where inline content is no node: the content ids read `null`.
{
  asserts,
  anonNodesFacts,
  anonNodesRel,
  anonNodesIds,
  anonNodesStitches,
  anonNodesSeam,
}:
let
  id =
    owner: steps:
    "${owner}/includes/${
      builtins.toJSON (
        [
          "a:2"
          "aspects"
          owner
          "includes"
        ]
        ++ steps
      )
    }";
  instanceOf = h: builtins.head anonNodesRel.reaches.${h}.gore;
  yokeInl = id "yoke" [ 0 ];
  yokeInn = id "yoke" [
    0
    "imports"
    0
    "includes"
    0
  ];
  welt = "welt/includes/${
    builtins.toJSON [
      "a:3"
      "aspects"
      "welt"
      "includes"
      0
    ]
  }";
  # a seam id is `seam/includes/<address>`: the declaring path module's anchor, then the option path
  seamAddress =
    i:
    let
      m = builtins.match "seam/includes/(.*)" i;
    in
    if m == null then null else builtins.fromJSON (builtins.head m);
  fromFile =
    file: i:
    let
      a = seamAddress i;
    in
    a != null
    && builtins.match "k.*%2Ffixtures%2Fanonymous-nodes%2F${file}" (builtins.head a) != null
    &&
      builtins.tail a == [
        "aspects"
        "seam"
        "includes"
        0
      ];
in
{
  construct = [ "anonymous-declarations-are-nodes" ];
  check = asserts (
    anonNodesFacts.nodes == [
      "cuff"
      (id "cuff" [ 0 ])
      "gore"
      "placard"
      (id "placard" [ 0 ])
      "welt"
      welt
      "yoke"
      yokeInn
      yokeInl
      (id "yoke" [ 1 ])
    ]
    && anonNodesFacts.parentOf.${yokeInn} == yokeInl
    && anonNodesFacts.parentOf.${yokeInl} == "yoke"
    && anonNodesFacts.parentOf.${welt} == "welt"
    && anonNodesFacts.unresolvedIncludesOf.${yokeInl} == [ 1 ]
    &&
      anonNodesIds "bodice" == [
        "yoke"
        (instanceOf "bodice")
        yokeInl
        (id "yoke" [ 1 ])
        "${instanceOf "bodice"}/includes/0"
        yokeInn
        null
      ]
    &&
      anonNodesIds "sleeve" == [
        "cuff"
        (instanceOf "sleeve")
        (id "cuff" [ 0 ])
        "${instanceOf "sleeve"}/includes/0"
      ]
    && instanceOf "bodice" != instanceOf "sleeve"
    &&
      anonNodesIds "collar" == [
        "welt"
        welt
      ]
    &&
      anonNodesIds "lapel" == [
        "placard"
        (id "placard" [ 0 ])
      ]
    &&
      anonNodesStitches == {
        bodice = [
          "yoke"
          "gore"
          "yoke-inl"
          "shared"
          "gore-inl"
          "yoke-inn"
          "piping"
        ];
        collar = [
          "welt"
          "edited"
        ];
        lapel = [
          "placard"
          "placard-inl"
        ];
        sleeve = [
          "cuff"
          "gore"
          "shared"
          "gore-inl"
        ];
      }
    && anonNodesSeam.frontBack == anonNodesSeam.backFront
    && builtins.length anonNodesSeam.frontBack == 2
    && builtins.any (fromFile "front.nix") anonNodesSeam.frontBack
    && builtins.any (fromFile "back.nix") anonNodesSeam.frontBack
  );
}
