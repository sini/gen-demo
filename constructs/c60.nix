# ── C60 — AN `internal` PRIMITIVE IS AN IDENTITY KEY (den-hoag-udh9m) ──
# `internal = true` is presentation only (hidden from generated docs). Among a kind's primitive
# options the declared `identity = false` is the one exclusion channel, so a system-owned field —
# `internal`, `readOnly`, a registry number — enters the identity like any other primitive.
#
# A NEW kind, `grommet`, because adding a key to a kind whose stamp is pinned elsewhere in this
# corpus would move that stamp. It declares `crimp` (plain), `lot` (internal, readOnly: the
# system-owned key under test) and `tally` (declared `identity = false`: the control that is NOT a
# key). `c60Brass` builds one instance named `brass` in a fresh registry, so two calls differing in
# one field are two same-named instances differing only in it.
{ genMerge, inputs }:
let
  c60Schema = inputs.gen.lib.substrate.schema;
  c60Kinds = c60Schema.evalSchema {
    modules = [
      {
        config.schema.grommet.options = {
          crimp = genMerge.mkOption { type = genMerge.types.str; };
          lot = genMerge.mkOption {
            type = genMerge.types.str;
            internal = true;
            readOnly = true;
          };
          tally = genMerge.mkOption { type = genMerge.types.str; } // {
            identity = false;
          };
        };
      }
    ];
  };
  c60Brass =
    { lot, tally }:
    (genMerge.evalModuleTree {
      modules = [
        {
          options.grommets = c60Schema.mkInstanceRegistry c60Kinds.grommet { };
          config.grommets.brass = {
            crimp = "rolled";
            inherit lot tally;
          };
        }
      ];
    }).config.grommets.brass;
in
{
  inherit c60Brass;
}
