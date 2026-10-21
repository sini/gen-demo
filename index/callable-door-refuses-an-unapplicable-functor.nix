{
  title = "a callable door refuses an unapplicable functor";
  adr = "0025";
  what = "`callable-door-refuses-an-unapplicable-functor`: a door that applies a caller's value admits what Nix can apply (gen-prelude's fuelled `isApplicable` walk), so a nested functor is served as its lambda while `{ __functor = _: 5; }` and a self-returning functor are refused catchably where their application aborted; a door that reads the value's pattern reads it on the function the argument meets, so a nested functor whose innermost lambda destructures is refused catchably too";
}
