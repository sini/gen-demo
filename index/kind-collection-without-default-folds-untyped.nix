{
  title = "a collection declaring no default folds untyped and is refused by name where it has no value";
  adr = "0025";
  what = "a `user` kind whose `roles` collection declares neither a `default` nor a `merge`, defining `roles = [ \"kind\" ]` beside a mixin's `[ \"mixin\" ]`, and a second kind that never defines it; the definitions fold as an untyped option's do, the kind's and then the mixin's, while the undefined collection is a catchable refusal by name and the kind is still minted";
}
