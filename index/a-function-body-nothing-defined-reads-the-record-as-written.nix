{
  title = "a function body nothing defined reads the record as written";
  adr = "0039, kc84t";
  what = "below a root whose fix-up rebuilds nothing (`either`, `oneOf`), nixpkgs' `functionTo` merges a function body nothing defined against the element record written there, so `either (attrsOf (functionTo (listOf sub // { emptyValue.value = \"EV\"; }))) int` reads \"EV\", as does the same through `lazyAttrsOf` below `oneOf` and through a `uniq` between `functionTo` and the record; with no stop above it the record is rebuilt and the body reads `[ ]`, and a body the record's check rejects is refused; gen-merge handed `functionTo` the element's export, built before the author's `//`, so it read `[ ]` where nixpkgs reads the record's own value";
}
