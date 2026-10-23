{
  title = "a collection's default is one definition of the collection, resolved alone";
  adr = "0029";
  what = "a `user` kind whose `classes` default carries `mkIf true` and `mkDefault` elements and whose `metadata` default carries a `mkIf true` key, beside one class from the kind and one from its mixin; the default is resolved alone, as an option's default is, and seeds the fold, so the elements and the key resolve and the definitions follow, while a `mkIf` at the top of a default is a catchable refusal by name";
}
