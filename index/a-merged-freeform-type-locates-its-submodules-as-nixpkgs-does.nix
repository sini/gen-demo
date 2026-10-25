{
  title = "a merged freeform type locates its submodules as nixpkgs does";
  adr = "0039, htwjd";
  what = "`freeform-merge-locates-its-submodules`: a freeform type defined by three modules, each an `attrsOf` submodule, reads each sub-option's `declarations` as the file that defined it, a sub-option two of them declare naming both in nixpkgs' module order, and a freeform type of one definition stays unlocated, each equal to nixpkgs' own `lib.evalModules` over the same loom, where gen-merge read `<unknown-file>`";
}
