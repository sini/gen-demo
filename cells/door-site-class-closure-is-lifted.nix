# `door-site-class-closure-is-lifted` — C202, den-hoag-p5k3k. A class closure written in a door's
# output is lifted into a nested door node and fires at the address the door's scope names: `seam` (over
# `bobbin` with the module arg `pkgs`) delivers `"seam-pewter-spool-P"`, `tack` (over the coordinate only)
# `"tack-spool"`, and `hem` its nested closure's `"hem-spool"` and then its class value `"hem-class-spool"`, beside a wrapped
# `includes`. Before, all three were refused by gen-aspects' door-result-shape check. A ranked wrapper on
# such a closure is refused by name (gen-rules' tests-error).
{
  asserts,
  c202Seam,
  c202Tack,
  c202Hem,
}:
{
  construct = [ "C202" ];
  check = asserts (
    c202Seam == [ "seam-pewter-spool-P" ]
    && c202Tack == [ "tack-spool" ]
    &&
      c202Hem == [
        "hem-spool"
        "hem-class-spool"
      ]
  );
}
