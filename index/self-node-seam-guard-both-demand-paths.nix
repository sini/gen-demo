{
  title = "the `self.node` seam guard, both demand paths";
  adr = "0008, 0030";
  what = "`codomain-seam-guard`: `damask` reads its sibling `faille`'s `ply` through `self.node`, once in a synthesized body and once in a circular attribute's step; under a declared relation carrying the edge both read `2`, under the empty relation both are refused, and gen-scope's reason names `damask`, `faille` and the relation `[]`; `damask`'s read of its own record is not refused";
}
