{
  title = "a foreign submodule option answers its configurations";
  adr = "0039, den-hoag-xroc7";
  what = "`foreign-submodule-value-meta`: an option declared with nixpkgs' `attrsOf (submodule …)` answers `valueMeta`, each element's `configuration` the value gen-merge's fold returned, so `lib.modules.mapAttrsOfSubmodule` reads each element's config and option priority as over nixpkgs' own `evalModules`, where gen-merge refused the read by name; a `verify` copy inside the submodule rejecting a definition refuses the value and the configuration carrying it alike";
}
