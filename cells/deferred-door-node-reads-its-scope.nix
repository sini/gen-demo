# `deferred-door-node-reads-its-scope` — C171, den-hoag-ohvjc. A closure aspect's vertex carries its
# instantiation scope, and a door node its firing left deferred, fired later per bobbin with that
# scope, reads its closure there and never re-applies the outer: through a door whose every closure
# throws, the scoped firings return their values. At depth 2 the closure is the middle one's, which
# fired in place inside the outer's firing. Control: the same firings with no scope take the door's
# fallback and throw. Before, `instanceOf` refused the `scope` field, and the only firing re-applied
# the outer once per bobbin.
{
  asserts,
  c171Selvage,
  c171Warp,
}:
{
  construct = [ "C171" ];
  check = asserts (
    c171Selvage == {
      scoped = [
        "fringe-pewter-linen"
        "fringe-pewter-silk"
        "fringe-pewter-wool"
      ];
      unscopedThrows = [
        true
        true
        true
      ];
    }
    &&
      c171Warp == {
        scoped = [
          "tassel-pewter-linen"
          "tassel-pewter-silk"
          "tassel-pewter-wool"
        ];
        unscopedThrows = [
          true
          true
          true
        ];
      }
  );
}
