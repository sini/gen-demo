{
  title = "a gen container over a checked copy is enforced in nixpkgs evaluation";
  adr = "0039 (Not covered: a gen container over a copy is gen's, f66c6 S′; den-hoag-umpfd)";
  what = "`gen-container-over-a-checked-copy-in-nixpkgs-evaluation`: a submodule copy with a check laid on (gen's with its check's functor replaced, nixpkgs `addCheck` over gen's, and nixpkgs `addCheck` over nixpkgs' own submodule), below gen `attrsOf`, `nullOr` and `listOf`, declared one to four times in nixpkgs' `lib.evalModules`, serves `{ a = 1; }` and `{ a = 3; }` and refuses `{ a = 2; }`, where nixpkgs' fixup rebuilt the container over the copy's base and served the rejected value";
}
