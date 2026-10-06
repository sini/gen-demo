# `wrapped-closure-is-lowered-as-unwrapped` — C201, den-hoag-crk5e. A closure under `mkIf` is lowered
# exactly as the same closure unwrapped, wherever it is written: in `includes = mkIf true [ … ]` (`hem`),
# under a module's `config = mkIf true { … }` (`pleat`), and at the class key `nixos = mkIf true …`
# (`seam`). Each equals its control in condition and firing; `seam` keeps its `has bobbin` guard and is
# delivered `"seam-spool"`, and `seamOff`'s `mkIf false` registers, keeps the same guard and delivers
# nothing. Before, `hem` and `pleat` were refused by gen-aspects' bare-closure refusal and `seam` was
# delivered with its guard dropped. A ranked wrapper at that class key is refused (row 161).

{
  asserts,
  c201Registrations,
  c201Hem,
  c201HemControl,
  c201Pleat,
  c201PleatControl,
  c201Seam,
  c201SeamControl,
  c201SeamOff,
  c201HasThimble,
  c201HasBobbin,
}:

{
  construct = [ "closure-under-a-property-wrapper" ];
  check = asserts (
    c201Registrations == 7
    && c201Hem.atPewter == { description = "hem-pewter"; }
    && c201Hem.condition == c201HasThimble
    && c201Hem == c201HemControl
    && c201Pleat.atPewter == { description = "pleat-pewter"; }
    && c201Pleat == c201PleatControl
    && c201Seam.atSpool == "seam-spool"
    && c201Seam.condition == c201HasBobbin
    && c201Seam == c201SeamControl
    &&
      c201SeamOff == {
        condition = c201HasBobbin;
        atSpool = "none";
      }
  );
}
