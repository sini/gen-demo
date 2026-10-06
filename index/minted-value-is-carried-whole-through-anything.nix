{
  title = "a minted value is carried whole through `anything`";
  adr = "0034";
  what = "`minted-value-carried-through-anything`: a `bobbin` kind carried through gen-merge's `anything`, `attrsOf anything` and `listOf anything` is one kind with itself under `kindEq`, and a refined type carried through `anything` is `typeEq` to itself, on Nix, Determinate and Lix alike, where the carrier rebuilt the attrset and `kindEq` refused it on Nix and Determinate and a refined type compared false there and overflowed uncatchably on Lix; `raw` is the control";
}
