# `function-pattern-shape-is-read` — den-hoag-gtwxg. gen-prelude's `patternOf`, reached through the
# hub's `substrate.prelude` bucket, reads a function's pattern shape: named, set with or without an
# ellipsis, or primop, functor-aware like `functionArgs`. It tells `{ ... }:` from `x:` and `{ }:`,
# which `functionArgs` reads alike as `{ }`. Red if the hub's prelude has no `patternOf` or any
# record departs from the hand-written one.
{ asserts, inputs }:
let
  prelude = inputs.gen.lib.substrate.prelude;
  read = prelude.patternOf;
in
{
  construct = [ "function-pattern-shape-is-read" ];
  check = asserts (
    prelude ? patternOf
    &&
      read (x: x) == {
        kind = "named";
        ellipsis = false;
        formals = { };
      }
    &&
      read ({ }: 1) == {
        kind = "set";
        ellipsis = false;
        formals = { };
      }
    &&
      read ({ a, ... }: a) == {
        kind = "set";
        ellipsis = true;
        formals = {
          a = false;
        };
      }
    &&
      read { __functor = self: { a }: a; } == {
        kind = "set";
        ellipsis = false;
        formals = {
          a = false;
        };
      }
    &&
      read builtins.map == {
        kind = "primop";
        ellipsis = false;
        formals = { };
      }
    # the distinction `functionArgs` cannot make
    && prelude.functionArgs ({ ... }: 1) == prelude.functionArgs (x: x)
    && read ({ ... }: 1) != read (x: x)
  );
}
