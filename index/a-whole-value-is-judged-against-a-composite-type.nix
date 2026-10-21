{
  title = "a whole value is judged against a composite type";
  adr = "0039, 0025";
  what = "`genMerge.verifyValue` over `attrsOf (listOf (submodule { gusset : int }))`: `{ thimble = [ { gusset = 1; } ]; }` judges `null` and a second entry stating `gusset = \"x\"` judges a string naming `thimble`, the second entry and `gusset`, where the fold serves the first and refuses the second";
}
