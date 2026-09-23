# `movement-dedup-equality` — C4b, den-hoag-behm0. A dedup decides on the relation its own
# constructor DECLARES, never on an encoding of it: `dedups.byDatum` says "structural equality on
# the datum itself", and structural equality in Nix is `==`. Two arms on `collisionGraph`'s shape,
# differing in one token. The reference's three identical data collapse 3 → 1 and record two drops,
# both licensed — that arm is what keeps the cell from being a `dropped == 0` check, which would
# pass the subject the moment the library over-corrected into refusing every dedup. The subject
# wraps one datum as `{ outPath = "cambric"; }`, which Nix `==` calls distinct from `[ "cambric" ]`
# and `builtins.toJSON` encodes identically to it: a dedup keyed on the encoding keeps ONE
# contribution and writes a `dropped` record asserting a duplicate that does not exist, so the
# caller is told two values were the same about two values that are not. The declared relation keeps
# TWO and records the one drop that is real. The oracle is read off the result alone, since
# `viewRelation` carries its `definition` inside the answer.
#
# C4b -- the dedup's decision is the relation the arm DECLARES, not an encoding
# of it. Two arms on one shape, differing in one token. The REFERENCE's three
# identical data collapse 3 -> 1 and record two drops, both licensed: that is what
# keeps this from being a `dropped == 0` check, which would pass the subject the
# moment the library over-corrected into refusing every dedup. The SUBJECT wraps
# one datum as `{ outPath = "cambric"; }` -- Nix-unequal to `[ "cambric" ]`,
# `toJSON`-identical to it -- so an encoding-decided dedup keeps ONE and records a
# drop asserting a duplicate that does not exist. The declared relation keeps TWO
# and records the one drop that is real.
{
  asserts,
  collisionCoerced,
  collisionDeduped,
  noFalseDedup,
}:
{
  construct = [ "C4b" ];
  check = asserts (
    builtins.length collisionDeduped.contributions == 1
    && builtins.length collisionDeduped.dropped == 2
    && noFalseDedup collisionDeduped
    && builtins.length collisionCoerced.contributions == 2
    && builtins.length collisionCoerced.dropped == 1
    && noFalseDedup collisionCoerced
  );
}
