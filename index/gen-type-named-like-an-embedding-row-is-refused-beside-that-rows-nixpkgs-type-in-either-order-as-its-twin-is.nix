{
  title = "a gen type named like an embedding row is refused beside that row's nixpkgs type in either order, as its twin is";
  adr = "0025 item 1, 0034, 0039, n8cpq";
  what = "`row-named-gen-type-refused-either-order`: one option `loom` declared by a gen type whose caller-chosen name is an embedding row's (gen-merge's `enum \"path\" [ \"/selvage\" ]` beside nixpkgs' `path`, a `defineType` named `string` checking only `\"selvage\"` beside nixpkgs' `str`) in both orders, under `genMerge.evalModuleTree` and `lib.evalModules`, equals its nixpkgs × nixpkgs twin (a nixpkgs type of that name and check): refused, where with nixpkgs declared first the gen type borrowed the row by its name and the option served a value its own check refuses; the closing case, gen-merge's `path` beside nixpkgs' `path`, still serves as its twin does";
}
