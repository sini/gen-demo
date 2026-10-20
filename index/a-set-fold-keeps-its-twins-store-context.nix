{
  title = "a set fold keeps its twins' store context";
  adr = "0034";
  what = "`folds-set-carries-twin-context`: `folds.set` keeps `[ \"b\" \"a\" \"c\" ]` of `[ \"b\" \"a\" \"b\" \"c\" \"a\" ]`, and two `==`-equal strings from different `toFile` paths collapse to one carrying 2 contexts, where nixpkgs' `unique` keeps 1";
}
