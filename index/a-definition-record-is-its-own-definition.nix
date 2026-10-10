{
  title = "a definition record is its own definition";
  adr = "0039 (serve half), 0025 item 1";
  what = "`definition-record-is-its-own-definition`: nixpkgs' `mkDefinition` record under `mkMerge` beside an `mkBefore` record reads `tabby = [ \"z\" \"a\" ]`, under `mkIf` reads `moire = true`, and `options.moire.files` names the record's file `/demo/selvage.nix`, each equal to nixpkgs on the same modules, where gen-merge refused the records; a record carrying `\"yes\"` on `bool` refuses catchably";
}
