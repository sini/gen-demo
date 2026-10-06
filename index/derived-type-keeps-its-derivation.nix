{
  title = "a derived type keeps its derivation";
  adr = "0034, 0025 item 1, den-hoag-5kic";
  what = "`derived-type-keeps-its-derivation`: gen-merge's `deriveType` over `str` (id `tagged`) merges with itself and stays tagged, is refused beside a bare `str` in both orders by gen-merge and by nixpkgs' own `lib.evalModules`, stays the element under `listOf`, and is not `typeEq` to `str`, where `str // { … }` merged to `str`, was absorbed by it and minted as it; a derivation closing its own cycle (`bobbin`, den-hoag-djbhc) mounted through nixpkgs' `lib.evalModules` renders its base's docs phrase and its refusal is caught; controls: `str` declared twice merges, two derivations of different ids refuse, and `bobbin` serves a definition in its domain";
}
