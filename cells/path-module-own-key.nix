# `path-module-own-key` — C180, den-hoag-mw1bg, den-hoag-3y4hb. A module imported by path is identified
# by the `key` its own content sets, else by its path, and a module's `_file` given as a path value is a
# string (nixpkgs' `unifyModuleSyntax`: `key = toString m.key or key`, `_file = toString m._file or
# file`). Two path modules sharing an in-file key are one module, so a list option reads the first
# one's value on both engines; gen-merge's old reading kept both (`[ 2 1 ]`). An attrset module with
# `_file = ./x.nix` reports a string file on both engines, where gen-merge's old reading was the path.
# The control: a keyed path module beside an unkeyed module is two modules, in one order, on both.
{
  asserts,
  genMerge,
  lib,
}:
let
  a = ../fixtures/path-module-own-key/a.nix;
  b = ../fixtures/path-module-own-key/b.nix;
  decl = L: { options.warp = L.mkOption { type = L.types.listOf L.types.int; }; };
  native = mods: (genMerge.evalModuleTree { } ([ (decl genMerge) ] ++ mods));
  nixpkgs = mods: (lib.evalModules { modules = [ (decl lib) ] ++ mods; });
  unkeyed.config.warp = [ 4 ];
  pathFiled = {
    _file = a;
    config.warp = [ 3 ];
  };
  ab = [
    a
    b
  ];
  ba = [
    b
    a
  ];
  control = [
    a
    unkeyed
  ];
  fileTypes = defs: map (d: builtins.typeOf d.file) defs;
in
{
  construct = [ "path-module-is-identified-by-its-own-key" ];
  check = asserts (
    (native ab).config.warp == [ 1 ]
    && (nixpkgs ab).config.warp == [ 1 ]
    && (native ba).config.warp == [ 2 ]
    && (nixpkgs ba).config.warp == [ 2 ]
    && fileTypes (native [ pathFiled ]).provenance.warp.defs == [ "string" ]
    && fileTypes (nixpkgs [ pathFiled ]).options.warp.definitionsWithLocations == [ "string" ]
    && (native control).config.warp == (nixpkgs control).config.warp
    && builtins.length (native control).config.warp == 2
  );
}
