{
  title = "a kind's collection left in its identity, holding a value that reads an instance of the kind";
  adr = "0034";
  what = "a `berth` kind whose `waivers` collection, not declared `identity = false`, holds a note built from a berth instance (den#719's shape, undeclared); the instance, the kind's mark, the instance's `id_hash` and the collection all evaluate, because the instance's import reads the kind's content cells and no identity cell, and a copy of the kind's sealed subjects is refused by name where its identity is read";
}
