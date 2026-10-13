# `container-status-read-off-the-fold` — den-hoag-ywitz, ADR-0039 parity-defect rule. A gen `nullOr` copied to
# take `attrsOf`'s fold (`split`, `mergeDefs`, `merge`) keeps `nullOr`'s name and takes `attrsOf`'s fold. The key
# walk and the fold read the record's container status off one datum, its fold's, so they agree on the copy:
# below nixpkgs' `either`, `{ j = { a = 1; }; }` is served at nixpkgs' twin's value, where the walk used to read
# the name and the evaluation aborted uncatchably (`'builtins.head' called on an empty list`).
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  np = lib.types;
  sub = t.submodule {
    options.a = genMerge.mkOption { type = t.int; };
    options.b = genMerge.mkOption {
      type = t.int;
      default = 0;
    };
  };
  copy = t.nullOr sub // {
    inherit (t.attrsOf sub) split mergeDefs merge;
  };
  read =
    (genMerge.evalModuleTree { } [
      { options.spool = genMerge.mkOption { type = np.either copy np.int; }; }
      { spool.j.a = 1; }
    ]).config.spool;
  r = builtins.tryEval (builtins.deepSeq read read);
in
{
  construct = [ "a-nullor-copy-taking-attrsofs-fold-serves-below-either" ];
  check = asserts (
    r.success
    &&
      r.value == {
        j = {
          a = 1;
          b = 0;
        };
      }
  );
}
