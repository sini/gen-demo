# `four-tier-provenance-join` — C114, den-hoag-zakjg U4 (ADR-0029, the owner's provenance
# obligation). gen-view's `joinedTrace` (U3, gen-view 47106a8) over gen-merge's real `bandedLeaves`
# records (U1): each surviving contribution is joined to its contributor, its head letter and the
# record of the evaluation it came from.
#   · join_k1–k4: contributor, head, priority and winner files, the expected literals.
#   · PAIRING (gate P1/p7): every joined record's winner files are among its contributor's OWN
#     modules' files. `joinedTrace` checks only that the record's `scope` is the contributor's; it
#     cannot see a record that stamps the right scope on the wrong evaluation. Red arm, same cell:
#     k1 with each scope stamped on the other's evaluation is joined by the library and fails here.
#   · `headOf(inner.band) == band` (gate P2): the head a record was placed at is the band its own
#     evaluation resolved.
#   · `loc` is the field (gate P3): `[ "x" ]` on every joined and unset record.
#   · NOTHING VANISHES: `unaccounted` is empty over k1–k6, and exactly `[ t ]` where a mark walls
#     the out-edge of a contributor whose moved datum the well-formedness predicate dropped (the
#     marked-contributor case, gen-view 47106a8's F1). The wall is what makes it F1's case: gen-view
#     before 47106a8 counted withheld edges as accounting for a datum and reads `[ ]` here, and
#     only with the wall; without it, both read `[ t ]`.
#
# Red, one seed each: mis-pairing every record (pairing); placing every record at `set` (head, on
# k3); a record whose `loc` is not the field (loc); dropping the well-formedness predicate, or
# gen-view at ece3973 (unaccounted reads `[ ]`).
{
  asserts,
  fourTier,
  genMerge,
}:
let
  ks = [
    "k1"
    "k2"
    "k3"
    "k4"
    "k5"
    "k6"
  ];
  files = r: map (w: w.file) r.winners;
  joinOf =
    k:
    map (e: {
      inherit (e) contributor band;
      inherit (e.inner) priority;
      files = files e.inner;
    }) (fourTier.case k { }).joined.joined;
  paired =
    c:
    builtins.all (
      e: builtins.all (f: builtins.elem f (c.ownFiles e.contributor)) (files e.inner)
    ) c.joined.joined;
  headed = c: builtins.all (e: fourTier.headOf.${e.inner.band} == e.band) c.joined.joined;
  located =
    c: builtins.all (r: r.loc == [ "x" ]) (map (e: e.inner) c.joined.joined ++ c.joined.unset);
  all = p: builtins.all (k: p (fourTier.case k { })) ks;
  marked = fourTier.channel {
    contributions = {
      r = [ "R" ];
      t = [ (genMerge.mkForce "TF") ];
      u = [ ];
    };
    edges.tacks =
      id:
      {
        r = [ "t" ];
        t = [ "u" ];
      }
      .${id} or [ ];
    expression = "tacks*";
    wellFormed = d: d != [ "TF" ];
    marks =
      pos: id:
      if id == pos.position "t" "force" then
        [
          {
            name = "wall";
            admits = _: false;
          }
        ]
      else
        [ ];
  };
  mispaired = fourTier.case "k1" {
    pairing =
      s:
      {
        r = "t";
        t = "r";
      }
      .${s};
  };
in
{
  construct = [ "C114" ];
  check = asserts (
    joinOf "k1" == [
      {
        contributor = "r";
        band = "set";
        priority = 100;
        files = [ "r.nix" ];
      }
    ]
    &&
      joinOf "k2" == [
        {
          contributor = "t";
          band = "set";
          priority = 100;
          files = [ "t.nix" ];
        }
      ]
    &&
      joinOf "k3" == [
        {
          contributor = "t";
          band = "default";
          priority = 1000;
          files = [ "t.nix" ];
        }
      ]
    &&
      joinOf "k4" == [
        {
          contributor = "t";
          band = "force";
          priority = 50;
          files = [ "t.nix" ];
        }
      ]
    && all paired
    # the red arm of the pairing: the library joins it, the pairing refuses it
    && map (e: e.contributor) mispaired.joined.joined == [ "r" ]
    && !(paired mispaired)
    && all headed
    && all located
    && all (c: c.joined.unaccounted == [ ])
    && map (r: r.scope) marked.joined.unaccounted == [ "t" ]
    && map (e: e.contributor) marked.joined.joined == [ "r" ]
    && map (r: r.scope) marked.joined.unset == [ "u" ]
  );
}
