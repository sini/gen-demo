{
  title = "an apply-only intake serves what Nix can apply";
  adr = "0025 item 1, k0whn";
  what = "`apply-only-intake-serves-what-nix-applies`: gen-bind's `contract.mk`/`contract.apply` serve an edge check given as a lambda, a functor over it, or a functor whose `__functor` is itself a functor, the value Nix's own call gives (`selvage`); a self-returning functor, on which Nix's call overflows, is refused catchably, where gen-bind aborted uncatchably with `stack overflow`; the lambda is the control";
}
