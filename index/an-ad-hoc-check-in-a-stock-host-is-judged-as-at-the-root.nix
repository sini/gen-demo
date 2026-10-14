{
  title = "an ad-hoc check in a stock host is judged as at the root";
  adr = "0039, 0025 item 1 (den-hoag-spb8r)";
  what = "`adhoc-check-in-a-stock-host`: inside gen-merge's `evalModuleTree`, a stock nixpkgs submodule's option typed by an ad-hoc `either // { check }` is judged as gen's root judges the same declared type: over a nixpkgs submodule the override is refused by name, the admitted value too, beside the plain `either`, which serves; over a gen submodule the check is enforced per definition, refusing the value it rejects and serving the value and the string it admits";
}
