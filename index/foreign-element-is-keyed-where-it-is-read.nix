{
  title = "a foreign element is keyed where it is read";
  adr = "0025 item 1, i2xjs";
  what = "`foreign-element-keyed-on-read`: gen-merge's own `attrsOf (coercedTo str f spool)`, and the same over `uniq spool`, `spool` a gen submodule, reads `heddle.k` as nixpkgs' value over its own types while the sibling `heddle.n` is outside the wrapper's domain (`5` under the coercion; two definitions under `uniq`), and `heddle.n` refuses catchably on both engines, where gen-merge aborted the read of `heddle.k` with `cannot coerce a set to a string`";
}
