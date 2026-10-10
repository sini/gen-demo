{
  title = "a `//` copy of a type is refused by name";
  adr = "0034, den-hoag-6orb8";
  what = "`type-copy-refused-by-name`: `spool // { verify = _: null; }` compared with `spool` is refused by name where it answered `true`; declared alone it serves \"x\", and beside `spool` in either order \"x\" is still refused; module-declared types decide as before; a description-only `//` is refused the same way at `typeEq`, where nixpkgs serves it: an open defect (the parity-defect rule), not a price";
}
