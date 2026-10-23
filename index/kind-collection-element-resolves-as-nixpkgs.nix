{
  title = "a kind's collection resolves its elements as nixpkgs does";
  adr = "0029";
  what = "a `user` kind's `classes` list holding `mkIf true` and `mkDefault` elements, and its `metadata` attrset holding a `mkForce` key over a later plain definition of it; the module system resolves each element's priority when it is read, so the values are the ones nixpkgs serves for a list or attrset option, and a `classes` defined as a string is a catchable refusal by name";
}
