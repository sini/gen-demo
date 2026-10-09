{
  title = "a read-only option's default counts as a setting";
  adr = "0039, 0025 item 1";
  what = "`read-only-default-counts-as-a-setting`: `spool`, declared `readOnly` with a default, refuses one definition beside the default, as nixpkgs' `defs'` counts it, and so does a `submodule` option holding a `mkDefault`; the default alone reads `1`, a lone definition with no default reads `2`, and two definitions are refused; by name in `refusals` row `read-only-default-counts-as-a-setting` (den-hoag-1gv6r)";
}
