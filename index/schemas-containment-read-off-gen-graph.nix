{
  title = "a schema's containment, read off gen-graph";
  adr = "0012";
  what = "`schema-containment-topology`: `damask` contains `faille`, which contains `picot` and `gusset`; `grosgrain` stands alone. `_roots` read `[ \"damask\" \"grosgrain\" ]`, `_leaves` `[ \"grosgrain\" \"gusset\" \"picot\" ]`, `picot`'s parent `faille`, and `faille`'s children `[ \"gusset\" \"picot\" ]` in kind-name order";
}
