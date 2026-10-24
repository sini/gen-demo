{
  title = "a disabled module is held to the evaluation's class";
  adr = "0039, den-hoag-zchgl";
  what = "`a-disabled-module-is-held-to-the-evaluations-class`: under `class = \"nixos\"` and a caller's `specialArgs._class = \"darwin\"`, a disabled nixos-class module is removed (a list option reads only the module kept) and a disabled darwin-class module is refused, on gen-merge and on nixpkgs' own `lib.evalModules`, where gen-merge held a disabled module to the caller's class; the `_class` argument reads `\"darwin\"` on both engines, the discriminator";
}
