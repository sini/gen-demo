{
  title = "function pattern shape is read";
  adr = "0014";
  what = "`function-pattern-shape-is-read`: the hub's `substrate.prelude.patternOf` reads a function's pattern as named, set with or without `...`, or primop, functor-aware like `functionArgs`, so a consumer tells `{ ... }:` from `x:` and `{ }:` without reading `builtins.toXML` itself";
}
