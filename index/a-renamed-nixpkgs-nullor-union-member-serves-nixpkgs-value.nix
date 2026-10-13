{
  title = "a renamed nixpkgs nullOr as a union member serves nixpkgs' value";
  adr = "0039, 0025 item 1 (den-hoag-i3kma)";
  what = "`renamed-foreign-nullor-union-member`: a nixpkgs `nullOr` over a gen submodule, its functor renamed so re-homing does not recognise it, as a nixpkgs `either` member under nixpkgs `attrsOf` and gen `lazyAttrsOf`, serves in gen's engine the value nixpkgs' engine serves its twin, as the un-renamed member does, where gen's walk read the element off any record named `nullOr` and aborted uncatchably";
}
