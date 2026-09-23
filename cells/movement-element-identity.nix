# `movement-element-identity` — C4b, den-hoag-2vzn. `diamondMoved`'s two-route arrival to
# `grosgrain` mints exactly ONE element (`value == [ "cambric" ]`, no refusal under `tieSet =
# refuse`); `collisionMoved`'s three declarations of identical content — two authored at
# `grosgrain`, one at `faille` — mint three, because element identity is the declaration coordinate
# `(producer, ordinal)` and never the content or the path that reached it. Both arms defeat the same
# two maskers: an asymmetric admission and a `labelOrder` with every letter in one layer.
#
# C4b — element identity: a diamond is one element (the two-route arrival to
# `grosgrain` collapses to `diamondMoved.value == [ "cambric" ]` and does not
# refuse under `tieSet = refuse`), and a collision is NOT a coincidence in content:
# `collisionGraph`'s three declarations -- two authored at `grosgrain`, one at
# `faille`, all three carrying the identical datum -- mint three elements, never
# fewer, because identity is the declaration coordinate `(producer, ordinal)` and
# never the content nor the path that reached it.
{
  asserts,
  collisionMoved,
  diamondMoved,
}:
{
  construct = [ "C4b" ];
  check = asserts (
    (builtins.tryEval (builtins.deepSeq diamondMoved.value diamondMoved.value)).success
    && diamondMoved.value == [ "cambric" ]
    && builtins.length collisionMoved.contributions == 3
    &&
      map (c: c.element.producer) collisionMoved.contributions == [
        "grosgrain"
        "grosgrain"
        "faille"
      ]
    &&
      builtins.length (
        builtins.attrNames (
          builtins.groupBy (e: builtins.toJSON e) (map (c: c.element) collisionMoved.contributions)
        )
      ) == 3
  );
}
