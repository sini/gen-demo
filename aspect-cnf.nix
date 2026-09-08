# THE DECLARATION INPUT, in one file both sides import.
#
# gen-delivery's projection reads a key's DECLARED category, never its shape (ADR-0028's Rider), and
# the declaration cannot be read back out of the compose result. So the `mkAspectSchema` argument
# lives here: `gen-modules/corpus.nix` builds the aspect grammar from it, and `flake.nix` hands the
# same value to the hub as `gen.aspectCnf`. Two copies would drift, and a drifted category is a class
# that silently stops realizing.
{
  keySemantics.nixos.category = "class";
}
