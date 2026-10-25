{
  title = "a module arguments set forced as a whole serves only what it forces";
  adr = "0025, 0039, b44rx";
  what = "`module-arguments-forced-as-a-whole`: a loom forcing its whole `_module.args` set, `mkForce { shuttle = 1; }`, at the top and in a gen `submodule` `bolt`; the arguments' keys, the `shuttle` read and the `name` found through `config._module.args` equal nixpkgs' `lib.evalModules` over nixpkgs' types, which serves the forced set alone, where gen-merge kept serving `extendModules`, `moduleType` and `bolt`'s position name beside it; a module reading `name` in the forced `bolt` is refused by name and catchably (its text is the refusals row `a-module-argument-a-forced-set-outranks-is-refused-by-name`), where nixpkgs aborts";
}
