{
  title = "a `//` copy's `verify` over a gen container is enforced inside a nixpkgs submodule";
  adr = "0039, dk6zg, 89s7p";
  what = "`verify-copy-over-a-gen-container-inside-a-nixpkgs-submodule`: a gen `listOf spool` with `// { verify = …; }` rejecting `[ \"weft\" ]`, declared as an option of a nixpkgs `submodule` (alone, two deep, under nixpkgs `attrsOf`, as a nixpkgs `listOf`'s element or a nixpkgs `attrTag`'s tag declared inside it), refuses `[ \"weft\" ]` and reads `[ \"warp\" ]`, where gen-merge served `[ \"weft\" ]` because the gen container's fold never reads the `verify` its copy replaced; an option never read is never judged";
}
