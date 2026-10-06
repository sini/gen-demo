{
  title = "a `path` option admits a string path as nixpkgs does";
  adr = "0025 item 1, fyx6m";
  what = "`path-type-admits-a-string-path`: a gen-merge option of type `path` defined as an absolute string, an interpolated `builtins.toFile` store path and an absolute `__toString` set is served and interpolates to the string nixpkgs' own `lib.evalModules` reads under `types.path` for the same definition, where gen-types' `path` refused all three with `builtins.isPath`; a relative string, refused on both engines, is the control";
}
