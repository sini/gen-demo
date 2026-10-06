{
  title = "a foreign eval mounts a bare gen module tree";
  adr = "0024 ruling 1, 0025 item 1";
  what = "`foreign-tree-mount`: nixpkgs' own `lib.evalModules` mounts the bare gen module tree `spool` (an `evalModuleTree` call's `.type`) and reads `sateen` and its default `none` through it, and under nixpkgs' `attrsOf`; the rendered docs of both (`visible && !internal`) equal nixpkgs' over its own `(lib.evalModules …).type`, where gen-merge refused the mount by name at `getSubModules`; a string definition is refused, catchably, here and by nixpkgs, as the control";
}
