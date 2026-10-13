# shellcheck shell=bash
# ── row fold-rewriting-copy-owes-its-own-check -- a `//` copy of a gen container that takes another
#    container's fold is refused BY NAME by its own check (den-hoag-u5jwx; ADR-0025 item 1) ──
# `attrsOf sub // { inherit (listOf sub) split mergeDefs merge; }` keeps `attrsOf`'s check over `listOf`'s
# fold. The fold carries the witness of the record it was completed with, so the copy's own check is owed,
# and a list definition is refused naming the copy's type, as nixpkgs' twin refuses it. The unplanted arm is
# the fold's own type over the same definition and asserts a STDOUT VALUE, so a library refusing every fold
# cannot pass it; the two arms differ by the option's type alone.
row_fold_rewriting_copy_owes_its_own_check='let
  merge = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules.merge;
  t = merge.types;
  sub = t.submodule {
    options.a = merge.mkOption { type = t.int; };
    options.b = merge.mkOption { type = t.int; default = 0; };
  };
  read = type: (merge.evalModuleTree { } [
    { options.spool = merge.mkOption { inherit type; }; }
    { _file = "/demo/spool.nix"; spool = [ { a = 1; } ]; }
  ]).config.spool;
  green = builtins.toJSON (read (t.listOf sub));
  red = builtins.toJSON (read (t.attrsOf sub // { inherit (t.listOf sub) split mergeDefs merge; }));
  caught = if (builtins.tryEval (builtins.deepSeq red red)).success then "SERVED" else "CAUGHT";
in BODY'
check "T5 fold-rewriting-copy-owes-its-own-check unplanted (the fold's own listOf serves the list)" \
  "${row_fold_rewriting_copy_owes_its_own_check/BODY/green}" 0 "" "$tmpdir/fold-rewriting-copy-owes-its-own-check-green.err" \
  '[{"a":1,"b":0}]'
check "T5 fold-rewriting-copy-owes-its-own-check planted   (an attrsOf copy with listOf's fold is refused by its own check)" \
  "${row_fold_rewriting_copy_owes_its_own_check/BODY/red}" 1 \
  "gen-merge: a definition for option \`spool' is not of type \`attribute set of (submodule)', in \`/demo/spool.nix'" \
  "$tmpdir/fold-rewriting-copy-owes-its-own-check-red.err"
check "T5 fold-rewriting-copy-owes-its-own-check catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_fold_rewriting_copy_owes_its_own_check/BODY/caught}" 0 "" "$tmpdir/fold-rewriting-copy-owes-its-own-check-catch.err" 'CAUGHT'
