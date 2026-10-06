{
  title = "a list element is named as nixpkgs' `listOf` names it";
  adr = "0025 item 1, 26thl";
  what = "`list-element-name-is-nixpkgs`: a gen `listOf` of a gen submodule reading `name`, over two definitions (the second holding a discharged `spool` before its survivor), names its elements `[definition 1-entry 2]` and `[definition 2-entry 1]` mounted in nixpkgs' own `lib.evalModules` and in gen-merge's `evalModuleTree`, nixpkgs' values over its own types, where gen-merge named both `\"0\"`";
}
