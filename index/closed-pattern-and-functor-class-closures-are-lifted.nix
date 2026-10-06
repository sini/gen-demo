{
  title = "closed-pattern and functor class closures are lifted";
  adr = "0025 item 1, den-hoag-iy9qh, den-hoag-ktnnu";
  what = "`closed-pattern-and-functor-class-closures-are-lifted`: under the mounted cnf of `module-function-aspect-serves-its-closure`, a class-key closure over `bobbin` written as a closed pattern (`{ bobbin }:`, `{ bobbin, pkgs }:`) or as a functor (`setFunctionArgs` form, bare `__functor`) lifts to a node guarded by `all [ has bobbin ]` and is delivered at a context with `bobbin`, as the open lambda `{ bobbin, ... }:` is; gen-rules' loader once aborted on each, past `tryEval`";
}
