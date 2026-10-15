{
  title = "a disabled module is removed with its imports";
  adr = "0025 item 1, 0039, den-hoag-7o7i9";
  what = "`a-disabled-module-is-removed-with-its-imports`: a path module that imports another and a keyed module, both named in `disabledModules`, are removed with the path module's import on gen-merge and on nixpkgs' own `lib.evalModules`, so a list option reads only the module kept, where gen-merge refused the key by presence; the same modules without `disabledModules` read every value on both engines, the discriminator";
}
