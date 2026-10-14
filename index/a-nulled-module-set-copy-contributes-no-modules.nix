{
  title = "a `//` copy stating `getSubModules = null` contributes no module set";
  adr = "0025 item 1, 0039, y4w78";
  what = "`nulled-module-set-copy`: a gen-merge `submodule` copied with `getSubModules = null`, at an option's root, inside a gen `attrsOf`, under a gen `nullOr`, and through the published `defineType`, declared twice is refused as `lib.evalModules` refuses its all-nixpkgs twin (the submodule declares nothing), and declared once or beside its plain twin in either order reads the value nixpkgs reads; gen-merge read the module set the copy carried from its base and served the twice-declared copy";
}
