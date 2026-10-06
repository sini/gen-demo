# `module-fn-beside-closure-serves-both` — C203, den-hoag-cgobz. A module function written beside a
# closure at one aspect key: the closure becomes a door node, so the key is a guard carrier, and the
# module function's closure is registered where the root reaches it. All four closures are registered
# (two at `pocket`, two at `pocketControl`), and `pocket` serves both, as `pocketControl` does, where the
# closure is written plainly. Before, three were registered and `pocket` served one.

{
  asserts,
  c203Registrations,
  c203Pocket,
  c203PocketControl,
}:

{
  construct = [ "C203" ];
  check = asserts (
    c203Registrations == 4
    &&
      c203Pocket == [
        "tuck-pewter"
        "hem-pewter"
      ]
    && c203Pocket == c203PocketControl
  );
}
