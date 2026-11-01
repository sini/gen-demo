{
  title = "a type stating the base module args it refuses from a caller";
  adr = "0039";
  what = "`refusingSubmodule null [ \"config\" ]`, gen's own construct with no nixpkgs twin: a caller's `config` is refused by name at its `withArgs` and at a redeclaration in either order, `argand` is served on both routes, and the plain `submodule` twin states nothing and mints apart";
}
