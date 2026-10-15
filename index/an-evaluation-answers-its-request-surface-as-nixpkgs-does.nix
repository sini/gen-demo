{
  title = "an evaluation answers its request surface as nixpkgs does";
  adr = "0039, l23bt, d2o0g";
  what = "`evaluation-answers-its-request-surface`: a loom evaluated with `class = \"nixos\"` and a carried `shuttle` specialArg reads `_class` in its modules and the result's `class`, `_type` and `graph`, and its `extendModules` at a stated prefix carries the class and the `shuttle` and places the option under the new prefix, each equal to nixpkgs' own `lib.evalModules` over the same loom, where gen-merge's door refused `class` by name";
}
