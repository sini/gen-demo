{
  title = "an ad-hoc check in a stock host is judged as at the root";
  adr = "0039, 0025 item 1 (den-hoag-spb8r, den-hoag-vjxra)";
  what = "`adhoc-check-in-a-stock-host`: inside gen-merge's `evalModuleTree`, a stock nixpkgs submodule's option typed by an ad-hoc `either // { check }` is judged as gen's root judges the same declared type: refused by name, as nixpkgs refuses it, over a nixpkgs submodule and over a gen one alike, the admitted value and string too, each beside the plain `either`, which serves them";
}
