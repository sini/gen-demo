{
  title = "a nullOr copy taking attrsOf's fold serves below either";
  adr = "0039, 0034 (den-hoag-ywitz)";
  what = "`container-status-read-off-the-fold`: gen `nullOr sub // { inherit (attrsOf sub) split mergeDefs merge; }` as nixpkgs' `either`'s first member serves `{ j = { a = 1; b = 0; }; }`, nixpkgs' twin's value, because the key walk reads the record's container status off its fold (`mergeDefs.container`), as the fold's guard does, where it read the name and the evaluation aborted uncatchably";
}
