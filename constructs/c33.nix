# ── C33 — the FUNCTION-headed T2b base this corpus shipped before `c544488`. gen-merge's
# `classifyModule` rules every function module dirty, so this warm run is admitted and
# reuses nothing; `trace.inert` is the field that now says so (den-hoag-0t9oh), where
# `trace.mode` alone read "warm" and hid it.
{
  inputs,
  t2bCtors,
  t2bEdit,
}:
let
  fnWarm =
    (inputs.gen.lib.compose {
      modules = [
        (
          { genMerge, ... }:
          {
            options.spool = genMerge.mkOption {
              type = genMerge.types.str;
              default = "linen";
            };
            options.ferrule = genMerge.mkOption {
              type = genMerge.types.str;
              default = "chased";
            };
          }
        )
      ];
      specialArgs = t2bCtors;
    }).override
      { modules = [ t2bEdit ]; };
in
{
  inherit fnWarm;
}
