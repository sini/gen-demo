{
  title = "a kind with a parent, its collection left in its identity, holding a value that reads an instance of the kind";
  adr = "0034";
  what = "a `berth` kind inheriting `dock`, whose `waivers` collection, not declared `identity = false`, holds a note built from a berth instance (den#719's shape, undeclared, on a kind that composes a parent); the instance, the kind's mark, the instance's `id_hash` and the collection all evaluate, because a kind that composes a parent is a graph node by its declaration node, read before composition, and its mark key is read only where another occurrence of its name meets it, so the instance's import reads no identity";
}
