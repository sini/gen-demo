{
  title = "mixins without a base are carried";
  adr = "0025";
  what = "a `user` kind on a schema declaring no `baseModule`, with one mixin contributing a collection element and an option: an absent base is the empty record, so the mixin is carried, read as the published collection, the kind's `options` and an instance's value; the same mixin over a function-module base is a catchable refusal by name, never a silent drop";
}
