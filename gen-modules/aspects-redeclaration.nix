# A SECOND, INDEPENDENT DECLARATION OF THE ASPECT CONTAINER (den-hoag-a0gc) — the corpus's exercise
# of `aspectsRoot`'s own type-merge relation.
#
# `gen-modules/corpus.nix` already declares `options.aspects`, via `mkAspectModule`. This file
# declares it AGAIN, through a second `mkAspectModule` over the same cnf, which answers with the same
# `aspectsRoot` container type. Not through `mkAspectOption`: that sibling does not thread the
# schema-declared instance options, so once `aspectsRoot` states its relation over its construction
# (den-hoag-bfc0k) the two are two constructions and are refused in either order. Two modules
# declaring one option is the ordinary shape of a
# federated tree — a framework declares the container, a consumer declares it too — and it is the
# shape that makes the module system reconcile the two DECLARED TYPES rather than merely their
# values.
#
# ★ WHY THIS REACHES THE RELATION, AND WHY NOTHING ELSE IN THIS CORPUS DOES. gen-merge's
# `redeclareDecl` (lib/modules.nix) calls `mergeTypes` exactly when BOTH declarations carry a
# `type`, and refuses BY NAME — "option `aspects' is declared with types that do not merge" — when
# the answer is null. With one declaration that path is never taken, so a corpus declaring the
# container once exercises the container's VALUES and never its IDENTITY. Measured on this corpus
# before this file existed: `aspectsRoot`'s `binOp` was not reached by any of the thirty-nine
# checks.
#
# ★ WHAT A FAILURE LOOKS LIKE, so the declaration cannot pass by being inert: a relation that
# refused its own kind would refuse HERE, at evaluation, naming `aspects` — the whole corpus stops
# rather than one cell reddening. That is the integration half of the unit suite's
# identical-declarations control (gen-aspects `ci/tests/root-type-merge.nix`): a mechanism that
# merely refuses everything passes every refusal cell and fails this declaration.
#
# NAMING: nothing here names an entity. The option is the one gen-aspects already publishes, and no
# kind, node or aspect word is introduced (ADR-0035).
args@{ genAspects, ... }:
(genAspects.mkAspectSchema (import ../aspect-cnf.nix)).mkAspectModule { } args
