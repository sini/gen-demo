{
  title = "an empty key below a union reads the record as written";
  adr = "0039, vy14u";
  what = "nixpkgs' `fixupOptionType` rebuilds a declared option's record only where the option's root states a module set, and a union (`either`, `oneOf`) or a copy with `getSubModules = null` states none, so below one a discharged key of a lazy container reads the record written there: `either (lazyAttrsOf (listOf sub // { emptyValue = { }; })) int` refuses and `// { emptyValue.value = \"EV\"; }` serves \"EV\", as does a nulled copy and a submodule below `oneOf`; with no stop above it the record is rebuilt and reads `[ ]`, and a submodule below the union is a root of its own; gen-merge rebuilt every record stating a module set wherever it sat, so it served `[ ]` (or the submodule's config) where nixpkgs refuses or serves the record's own value";
}
