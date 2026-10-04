# `path-module-own-file` — C169, den-hoag-6fqay. A module imported by path is named by the `_file` its
# own content sets, else by its path (nixpkgs' `unifyModuleSyntax`: `toString m._file or file`). A
# gen-merge definition from a path module that sets `_file` reports that file in `provenance`, whether
# the module is a tree's own entry, imported by another module or named by an absolute string, each
# equal to the file nixpkgs' own `lib.evalModules` reads for the same module; gen-merge's old reading
# was the path itself. A path module with no `_file` is named by its path on both engines, which is
# the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  named = ../fixtures/path-module-own-file/named.nix;
  plain = ../fixtures/path-module-own-file/plain.nix;
  shapes = m: {
    entry = [ m ];
    imported = [ { imports = [ m ]; } ];
    stringPath = [ (toString m) ];
  };
  native =
    mods:
    map (d: d.file)
      (genMerge.evalModuleTree { } (
        [ { options.warp = genMerge.mkOption { type = genMerge.types.int; }; } ] ++ mods
      )).provenance.warp.defs;
  nixpkgs =
    mods:
    map (d: d.file)
      (lib.evalModules {
        modules = [ { options.warp = lib.mkOption { type = lib.types.int; }; } ] ++ mods;
      }).options.warp.definitionsWithLocations;
in
{
  construct = [ "C169" ];
  check = asserts (
    builtins.all (n: native (shapes named).${n} == [ "/loom/named.nix" ]) (
      builtins.attrNames (shapes named)
    )
    && builtins.all (n: nixpkgs (shapes named).${n} == [ "/loom/named.nix" ]) [
      "entry"
      "imported"
    ]
    && native [ plain ] == [ (toString plain) ]
    && nixpkgs [ plain ] == [ (toString plain) ]
  );
}
