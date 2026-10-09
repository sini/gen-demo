{
  title = "nixpkgs renamed-option modules compose";
  adr = "0039";
  what = "`renamedOptions`: stock `lib.mkRenamedOptionModule` and `lib.mkAliasOptionModule` on a gen-merge tree, one option defined through each alias; `doRename`'s alias leaf reads its target's `type` off `options`, which the declaration guard resolves in a staged pass against the pass before, so both values serve and the rename warns as nixpkgs warns";
}
