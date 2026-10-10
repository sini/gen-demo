# `definition-record-is-its-own-definition` — a record from nixpkgs' `mkDefinition`, under `mkMerge`
# beside an `mkBefore` record, sorts `tabby` to `[ "z" "a" ]`; under `mkIf` it serves `moire`; and
# `options.moire.files` names the record's file. Each equals nixpkgs on the same modules, where gen-merge
# refused the records. A record carrying `"yes"` on `bool` refuses catchably.
{
  asserts,
  selvageGen,
  selvageNixpkgs,
  selvagePlanted,
}:
let
  expected = {
    tabby = [
      "z"
      "a"
    ];
    moire = true;
    moireFiles = [ "/demo/selvage.nix" ];
  };
in
{
  construct = [ "a-definition-record-is-its-own-definition" ];
  check = asserts (
    selvageNixpkgs == expected
    && selvageGen == selvageNixpkgs
    && !(builtins.tryEval (builtins.deepSeq selvagePlanted selvagePlanted)).success
  );
}
