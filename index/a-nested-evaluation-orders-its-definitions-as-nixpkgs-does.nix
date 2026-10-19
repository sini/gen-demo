{
  title = "a nested evaluation orders its definitions as nixpkgs does";
  adr = "0034, 0039, yjmwc";
  what = "`gen-nesting-types-read-their-own-modules-first`: a loom declaring a gen `submodule` option `frame` and an `attrsOf submodule` option `bolts`, whose own module states `threads = [ \"warp\" ]` and imports one stating `[ \"selvage\" ]`, with `loom.nix` and `shed.nix` each defining `threads`; both read `[ \"selvage\" \"warp\" \"loom\" \"shed\" ]`, equal to nixpkgs' `lib.evalModules` over nixpkgs' types, which locates a once-declared type's own modules one level below the definitions and reads them first. gen-merge read them after the definitions, `[ \"selvage\" \"loom\" \"shed\" \"warp\" ]`; the location is now an order of the child's top level taken after each module's coordinate, so no module node moves";
}
