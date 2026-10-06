{
  title = "a path module is named by its own `_file`";
  adr = "0025 item 1, 0039, den-hoag-6fqay";
  what = "`path-module-own-file`: a module imported by path that sets `_file = \"/loom/named.nix\"` reports that file in `provenance` as a tree's own entry, imported by another module and named by an absolute string, the first two equal to nixpkgs' own `lib.evalModules` for the same module, where gen-merge reported the module's path; a path module with no `_file` is named by its path on both engines, the control";
}
