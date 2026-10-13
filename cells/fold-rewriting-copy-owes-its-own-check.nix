# `fold-rewriting-copy-owes-its-own-check` — den-hoag-u5jwx, ADR-0025 item 1. A `//` copy of a gen `attrsOf`
# that takes `listOf`'s fold (`split`, `mergeDefs`, `merge`) keeps `attrsOf`'s own `check`, and the fold it took
# carries the check witness of the record it was completed with, so the two disagree and the copy's own check
# is owed: a list definition is refused by name, naming the copy's own type, where the copy used to serve the
# fold's value past its check. nixpkgs' twin refuses it too (its `mergeDefinitions` asks the copy's `check`).
# The fold's own type still serves the same definition, so a refusal of everything cannot pass. The refusal
# is by name in the `refusals` row `fold-rewriting-copy-owes-its-own-check`.
{
  asserts,
  genMerge,
}:
let
  t = genMerge.types;
  sub = t.submodule {
    options.a = genMerge.mkOption { type = t.int; };
    options.b = genMerge.mkOption {
      type = t.int;
      default = 0;
    };
  };
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.spool = genMerge.mkOption { inherit type; }; }
      { spool = v; }
    ]).config.spool;
  decides = v: (builtins.tryEval (builtins.deepSeq v null)).success;
  copy = t.attrsOf sub // {
    inherit (t.listOf sub) split mergeDefs merge;
  };
in
{
  construct = [ "a-copy-taking-another-containers-fold-is-refused-by-its-own-check" ];
  check = asserts (
    read (t.listOf sub) [ { a = 1; } ] == [
      {
        a = 1;
        b = 0;
      }
    ]
    && !(decides (read copy [ { a = 1; } ]))
    && !(decides (read (genMerge.mkOptionType copy) [ { a = 1; } ]))
  );
}
