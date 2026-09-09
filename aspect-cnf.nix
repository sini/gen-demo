# THE DECLARATION INPUT, in one file both sides import.
#
# gen-delivery's projection reads a key's DECLARED category, never its shape (ADR-0028's Rider), and
# the declaration cannot be read back out of the compose result. So the `mkAspectSchema` argument
# lives here: `gen-modules/corpus.nix` builds the aspect grammar from it, and `flake.nix` hands the
# same value to the hub as `gen.aspectCnf`. Two copies would drift, and a drifted category is a class
# that silently stops realizing.
#
# v1 adds C6's two Rider limbs (ADR-0028), both planted in `gen-modules/corpus.nix`'s `aspects.stitch`
# body and both must NOT realize as a delivery class:
#   `welt`   — declared `category = "channel"`, carrying a module. A channel rides its value verbatim
#              to whoever reads it; it is never a delivery class regardless of what its value looks
#              like, which is exactly the shape test ADR-0028's Rider forbids gen-delivery from doing.
#   `gusset` — declared `category = "class"`, valued `null` in the body — gen-aspects' own
#              representable absence of a declared-but-unset class. `null` never carries content, so
#              it never realizes either, for a different reason than `welt`'s: `welt`'s category says
#              "never a class"; `gusset`'s category says "a class", but its content says "nothing here".
{
  keySemantics.nixos.category = "class";
  keySemantics.welt.category = "channel";
  keySemantics.gusset.category = "class";
}
