# `attrs-undefined-yields-empty` — C23, den-hoag-241d7. An `attrs` option with no definition
# anywhere and no `default` resolves to `{ }`. Reads the VALUE and never a `tryEval` bit: a repair
# that yields `null`, or a nested shape, still "succeeds", and only an equality catches it.
#
# C23 — an undefined, defaultless `attrs` option IS the empty container, not a
# throw. Reads the VALUE and not a `tryEval` success bit: the failure this cell has
# to catch is a repair that makes the option resolve to `null`, or to a nested
# shape, while still "succeeding" — a bit-reading cell passes all of those.
# DRIVEN RED: dropping `whenEmpty.value` from the construction reds THIS cell and
# leaves the union cell below green.
{ asserts, c23Undefined }:
{
  construct = [ "C23" ];
  check = asserts (c23Undefined == { });
}
