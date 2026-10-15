{
  title = "a foreign option answers nixpkgs' v2-merge metadata";
  adr = "0039, den-hoag-xroc7";
  what = "`foreign-option-value-meta`: an option declared with nixpkgs' `attrsOf str` answers `valueMeta.attrs` naming its definitions' attributes and `valueMeta._internal.type` as its own type, and a `str` answers `{ }`, on gen-merge's evaluated record as in nixpkgs' own `evalModules`, where gen-merge refused the read by name; an option of gen-merge's own `attrsOf str` still refuses it catchably, beside its served value";
}
