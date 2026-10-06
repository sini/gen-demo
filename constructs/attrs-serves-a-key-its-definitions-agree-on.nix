# ── C195 — `attrs` SERVES A KEY ITS DEFINITIONS AGREE ON (den-hoag-t1j4z, ADR-0039). C23's fold
# unions disjoint keys; two modules that set ONE key refused whatever their values, so two hands
# writing the same `warp = "flax"` were told they collided. Equal values lose nothing, so the key
# serves nixpkgs' value; different values refuse, and refuse only where that key is read: the
# key's siblings still read.
#
# On C23's `selvedge` vocabulary, declared here rather than borrowed, for C15's reason.
{ genMerge }:
let
  c195Decl = {
    options.selvedge = genMerge.mkOption { type = genMerge.types.attrs; };
  };
  # Both modules set `warp`, to one value.
  c195Agreeing =
    (genMerge.evalModuleTree { } [
      c195Decl
      { config.selvedge.warp = "flax"; }
      {
        config.selvedge = {
          warp = "flax";
          weft = "tussah";
        };
      }
    ]).config.selvedge;
  # The same modules with `warp` disagreeing: `warp` refuses, `weft` reads.
  c195Disagreeing =
    (genMerge.evalModuleTree { } [
      c195Decl
      { config.selvedge.warp = "flax"; }
      {
        config.selvedge = {
          warp = "linen";
          weft = "tussah";
        };
      }
    ]).config.selvedge;
in
{
  inherit c195Decl c195Agreeing c195Disagreeing;
}
