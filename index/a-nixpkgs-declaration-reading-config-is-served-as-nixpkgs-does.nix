{
  title = "a nixpkgs declaration reading config is served as nixpkgs does";
  adr = "0033, 0039, 2tna3";
  what = "`a-nixpkgs-declaration-reading-config-is-served`: a `lib.mkOption` declaration whose default is chosen by reading `config` at declaration time (grav's shape) serves nixpkgs' own `lib.evalModules` value; the same declaration with a gen type is refused catchably (its text is the refusals row `a-gen-declaration-reading-config-is-refused-by-name`), and a declaration reading nothing is the control";
}
