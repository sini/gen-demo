{
  title = "an aspect's identity is its declared path, not `name` or its chain";
  adr = "0034 rider, 0012, 0cmbt, qseuh";
  what = "`aspect-identity-inputs-read-only`: a static that overrides its `name` to another's keeps its own key and id and a by-value include of it resolves to it; a `meta.aspect-chain` contradicting the declared path is refused by name; the chain the type would stamp is no contradiction; a typed value included by value, and an alias at a tree position, keep the identity they carry; a guard declaring its own `name` keeps its declared path; two modules writing one named `includes` element each, swapped, move neither element's key nor id, each keyed by its declaring site under its owner";
}
