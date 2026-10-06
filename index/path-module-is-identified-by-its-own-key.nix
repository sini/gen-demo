{
  title = "a path module is identified by its own `key`";
  adr = "0025 item 1, 0039, den-hoag-mw1bg";
  what = "`path-module-own-key`: two modules imported by path that each set `key = \"loom-key\"` are one module, so a list option reads the first one's value in either order on gen-merge and on nixpkgs' own `lib.evalModules`, where gen-merge kept both (`[ 2 1 ]`); an attrset module with `_file` given as a path value reports a string file on both engines, where gen-merge reported the path; a keyed path module beside an unkeyed module is two modules on both, the control";
}
