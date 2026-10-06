{
  title = "a module imported twice is one node";
  adr = "den-hoag-470xp, 0018";
  what = "`module-graph-identity`: two modules keyed `heddle` read `threads = [ \"twill\" ]` and `reed.nix` imported by two modules reads `[ \"reed\" ]`, each one node (a diamond is two import edges into it), where both contributed twice; an anonymous module imported by two parents stays two nodes, `[ \"sley\" \"sley\" ]`, the control; the path cycle `warp.nix` ⇄ `weft.nix` terminates, `[ \"weft\" \"warp\" ]`, where it overflowed the stack (nixpkgs overflows too: a named byte-mode boundary)";
}
