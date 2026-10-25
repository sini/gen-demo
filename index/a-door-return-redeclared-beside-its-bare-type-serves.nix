{
  title = "a container returned by the `mkOptionType` door, redeclared beside its bare type, serves nixpkgs' value";
  adr = "0039, bkmiz";
  what = "`door-returned-container-beside-its-bare-twin`: gen `attrsOf`, `lazyAttrsOf` and `deferredModule` (and nixpkgs' `attrsOf` and `attrsWith`) returned by `types.mkOptionType`, declared beside the bare type in either order and one level down under `listOf`, serve the value nixpkgs' `lib.evalModules` serves over the same declarations, where gen-merge refused them for every element as \"a partner that states no element type of its own\"; a value the door element's check rejects is refused by the meet, and a laziness clash and a raw `listOf` stating `lazy` beside its element stay refused";
}
