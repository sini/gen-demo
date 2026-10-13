{
  title = "a copy taking another container's fold is refused by its own check";
  adr = "0025 item 1, 0039 (den-hoag-u5jwx)";
  what = "`fold-rewriting-copy-owes-its-own-check`: gen `attrsOf sub // { inherit (listOf sub) split mergeDefs merge; }` over `[ { a = 1; } ]`, raw and through `mkOptionType`, is refused by name, naming `attribute set of (submodule)`, where it used to serve the list fold's value past its own check; `listOf sub` itself serves `[ { a = 1; b = 0; } ]`; the refusal is by name in the `refusals` row `fold-rewriting-copy-owes-its-own-check`";
}
