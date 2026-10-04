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
#
# The body vocabulary is CLOSED (C111). Under gen-aspects' open default an undeclared body key
# becomes a nested aspect, so a misspelt `nixos` emptied `nixosConfigurations` at exit 0. With
# `closedKeys`, a key at an aspect body's first level that is neither declared above nor listed in
# `freeformKeys` is refused by name, with its aspect. `freeformKeys` carries two grammars. Its
# attribute NAMES are exactly the corpus's intended undeclared body keys: `binding` and `trim` are
# the two freeform witnesses of `multidef-witness.nix`, kept undeclared so they keep exercising the
# freeform merge, and `placket` and `facing` are C16's nested aspects under `hemline`. A listed key
# opens an UNGATED subtree, so the closure holds at the first level only: a typo below `placket`
# still nests silently (`aspect-body-key-below-listed` pins that). Its node IDS (the entries holding
# a `/`) declare C16's three placeholder nodes intended, which is what keeps `graphFacts`' dead-nested
# warning silent over this corpus (den-hoag-l62pz); an id holds a `/`, which an ordinary attribute name
# does not, so it exempts no such name at the gate (a body key spelled with that exact string would
# match), and it silences that one node, never a same-named stray elsewhere. Hence `placket` and
# `facing` are listed twice, once as the key the gate asks for and once as the node the warning asks for; `eyelet`,
# below a listed key, is listed once, as an id.
{
  keySemantics.nixos.category = "class";
  closedKeys = true;
  freeformKeys = [
    "binding"
    "trim"
    "placket"
    "facing"
    "hemline/placket"
    "hemline/placket/eyelet"
    "hemline/facing"
  ];
  keySemantics.welt.category = "channel";
  keySemantics.gusset.category = "class";
}
