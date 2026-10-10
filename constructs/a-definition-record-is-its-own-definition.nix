# ── A DEFINITION RECORD IS ITS OWN DEFINITION (ADR-0039 serve half, ADR-0025 item 1). nixpkgs'
# `lib.mkDefinition { file; value; }` is a definition in its own file, read right after discharge:
# legal under `mkMerge` and `mkIf`, with the one override or order level below it read. gen-merge
# served the record itself as the value, or refused it, and named the enclosing module's file.
#
# The same modules over each engine's own vocabulary, with the record from nixpkgs' constructor.
{ genMerge, lib }:
let
  record = file: value: lib.mkDefinition { inherit file value; };
  selvageModules = P: [
    {
      options.tabby = P.mkOption { type = P.types.listOf P.types.str; };
      options.moire = P.mkOption { type = P.types.bool; };
    }
    {
      _file = "/demo/warp.nix";
      config.tabby = P.mkMerge [ (record "/demo/selvage.nix" [ "a" ]) ];
      config.moire = P.mkIf true (record "/demo/selvage.nix" true);
    }
    {
      _file = "/demo/weft.nix";
      config.tabby = record "/demo/heddle.nix" (P.mkBefore [ "z" ]);
    }
  ];
  selvageRead = r: {
    inherit (r.config) tabby moire;
    moireFiles = r.options.moire.files;
  };
in
{
  selvageGen = selvageRead (genMerge.evalModuleTree { } (selvageModules genMerge));
  selvageNixpkgs = selvageRead (lib.evalModules { modules = selvageModules lib; });
  # A record whose value the declared check rejects.
  selvagePlanted =
    (genMerge.evalModuleTree { } [
      { options.moire = genMerge.mkOption { type = genMerge.types.bool; }; }
      { config.moire = record "/demo/selvage.nix" "yes"; }
    ]).config.moire;
}
