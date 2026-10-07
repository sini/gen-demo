{
  title = "a nixpkgs leaf and its gen twin under another functor name or payload serve in either order";
  adr = "0025 item 1, 0039, 46zga";
  what = "`leaf-functor-name-redeclared-either-order`: one option `loom` declared by nixpkgs' `str` and gen-merge's `str` (gen-types' `string`), and by nixpkgs' `path` and gen-merge's `path`, in both orders, under `genMerge.evalModuleTree` and `lib.evalModules`, equals its nixpkgs × nixpkgs twin, record name included, where it refused (`str`) or served gen's record in one order and aborted in the other (`path`); the closing case, nixpkgs' `pathInStore` beside gen-merge's `path`, refuses in both orders on both engines as its twin does, where both engines served a non-store path with nixpkgs declared first; the control, gen × gen `str`, keeps gen's record";
}
