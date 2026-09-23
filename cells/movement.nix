# `movement` — C4. The movement's value, and Λ read off C3's own relata names by construction.
#
# C4 — the movement, and Λ read off C3's own relata.
{
  asserts,
  bastingRelata,
  moved,
}:
{
  construct = [ "C4" ];
  check = asserts (
    moved.value == [ "cambric" ]
    &&
      builtins.attrNames bastingRelata == [
        "warp"
        "weft"
      ]
  );
}
