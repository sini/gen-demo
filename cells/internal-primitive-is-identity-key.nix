# `internal-primitive-is-identity-key` — C60, den-hoag-udh9m. Two `brass` grommets differing only
# in `lot`, an `internal`, `readOnly` primitive, mint distinct identities, and `lot` is in
# `_identityKeys`; two differing only in `tally`, declared `identity = false`, mint ONE identity.
# The pair is the statement: `internal` does not exclude, the declared opt-out does. A gen-schema
# whose reflection still read `internal` reds the first half; one that dropped the opt-out reds
# the second.
{ asserts, c60Brass }:
let
  a = c60Brass {
    lot = "L-0417";
    tally = "12";
  };
in
{
  construct = [ "C60" ];
  check = asserts (
    a.id_hash != (c60Brass {
      lot = "L-0418";
      tally = "12";
    }).id_hash
    &&
      a.id_hash == (c60Brass {
        lot = "L-0417";
        tally = "40";
      }).id_hash
    &&
      a._identityKeys == [
        "crimp"
        "lot"
        "name"
      ]
  );
}
