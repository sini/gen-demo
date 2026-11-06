# `an-applied-sighting-joins-its-static-twin-whatever-its-co-members` — aspect-applied-sighting-joins-
# its-static-twin, den-hoag-c4ucc arm (D). `twine`'s two `cord` members (the int the mint takes and the
# `==` float it refuses) are one static class; `mooring`, reaching `twine` and `hitch`'s applied int,
# receives that one `cord` id and no content-keyed one; `davit`'s applied float is keyed within its own
# instance, under `cord`'s key, never the static id. Ids are asserted by their structure (the `name`
# position is a store path, which moves with the corpus source). Red where the join is gated on every
# member of the static class minting: `mooring` also receives `<cord key>/aspect-content:<digest>`.
{
  asserts,
  twinFacts,
  twinIds,
}:
let
  at = l: i: if builtins.length l > i then builtins.elemAt l i else "<none>";
  statics = twinFacts.includesOf.twine;
  staticId = at statics 0;
  cords = h: builtins.filter (n: builtins.match "@/includes/cord@.*" n != null) (twinIds h);
  davitCord = at (cords "davit") 0;
in
{
  construct = [ "an-applied-sighting-joins-its-static-twin-whatever-its-co-members" ];
  check = asserts (
    builtins.match "@/includes/cord@[^/]*" staticId != null
    &&
      statics == [
        staticId
        staticId
      ]
    && cords "mooring" == [ staticId ]
    && builtins.length (cords "davit") == 1
    && builtins.match "@/includes/cord@[^/]*/aspect-instance:.+" davitCord != null
    && davitCord != staticId
  );
}
