{
  title = "an evalSchema mixed-depth diamond composes once";
  adr = "0012, 0016, 0034";
  what = "`an-evalschema-mixed-depth-diamond-composes-once`: under `evalSchema`, `cloth` inherits `selvage` directly and through the shallower `warp`; `selvage` composes once in `cloth`, under gen-merge and in a nixpkgs `lib.evalModules` mount, and `warp` mounted beside the tree's `selvage` reads one `selvage`, and `loom`, a shallower kind defaulting an option to the tree's `cloth`, holds that same `cloth`; where one evaluation per inheritance depth built its own `selvage`, the key refused the two";
}
