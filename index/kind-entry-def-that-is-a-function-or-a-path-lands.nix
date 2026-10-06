{
  title = "a kind entry def that is a function or a path lands";
  adr = "0025 item 1, den-hoag-ndwvn";
  what = "`kind-entry-function-and-path-defs-land`: `config.schema.aspect` given `{ ... }: { priority = 7; }`, a module function `{ ... }: { config.priority = 7; }` and a path to a file holding `{ priority = 7; }`, each beside a declared `options.priority` (default 0), reads 7 on an aspect, as gen-schema's default branch and nixpkgs' own `submodule` read it, where gen-aspects' `mkType` dropped the function and the path and read 0 with no message; an attrset def (7) and no def (0) are the controls";
}
