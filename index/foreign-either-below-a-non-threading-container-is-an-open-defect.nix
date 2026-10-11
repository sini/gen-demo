{
  title = "a foreign `either` below a non-threading container is an open defect";
  adr = "0039, den-hoag-p06j3";
  what = "`foreign-either-below-a-non-threading-container`: nixpkgs' `either` and `oneOf` holding a gen submodule, below nixpkgs' `coercedTo` or `uniq`, are refused by name where nixpkgs serves the value: an open defect (the parity-defect rule), not a price; the same `either` at the root, and a gen `either` under `coercedTo`, are served on both sides";
}
