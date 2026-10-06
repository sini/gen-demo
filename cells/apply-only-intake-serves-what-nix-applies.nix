# `apply-only-intake-serves-what-nix-applies` — C153, den-hoag-k0whn. gen-bind's `contract` applies its
# `check` and never reads formals, so it serves every value Nix can apply: the lambda, a functor over it,
# and a functor whose `__functor` is itself a functor read `selvage` alike. A self-returning functor,
# which Nix's own call overflows on, is refused catchably, where gen-bind aborted uncatchably with
# `stack overflow`. The lambda is the control.

{
  asserts,
  isSelvage,
  edgeChecked,
}:

{
  construct = [ "apply-only-intake-serves-what-nix-can-apply" ];
  check = asserts (
    map edgeChecked [
      isSelvage
      { __functor = _: isSelvage; }
      { __functor.__functor = _: _: isSelvage; }
    ] == [
      "selvage"
      "selvage"
      "selvage"
    ]
    && !(builtins.tryEval (edgeChecked {
      __functor = self: self;
    })).success
  );
}
