{
  title = "a kind whose parent keeps a collection in its identity, holding a value that reads an instance of the kind";
  adr = "0034";
  what = "a `berth` kind inheriting `dock`, where the dock's `waivers` collection, not declared `identity = false`, holds a note built from a berth instance (den#719's shape, undeclared, on the parent); the instance, both marks, the instance's `id_hash` and the collection all evaluate, because the berth composes the dock by the construction it is and reads no mark to do it, while a `//` copy over the dock's mark is refused where the berth's mark is read";
}
