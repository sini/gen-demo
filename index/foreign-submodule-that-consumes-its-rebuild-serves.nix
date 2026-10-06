{
  title = "a foreign submodule that consumes its rebuild serves";
  adr = "0024 ruling 1, 0025 item 1, f8mgj";
  what = "`foreign-submodule-consumer-serves`: nixpkgs `attrTag` given a gen `submodule` element, and a payload-null `mkOptionType` copy of a nixpkgs freeform `submodule` over it, each read what nixpkgs' own `lib.evalModules` reads (mounted at the option root as `fixupOptionType` mounts it) where gen-merge aborted uncatchably; that copy with a null `substSubModules` and `getSubModules` is refused catchably; nixpkgs `attrsWith` with a non-default `placeholder` over the same element, which forwards the module list, serves `sateen` and is the control";
}
