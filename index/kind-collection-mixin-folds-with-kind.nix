{
  title = "a mixin's collection value folds with the kind's own";
  adr = "0039";
  what = "a `user` kind whose mixin contributes `classes` elements under `mkIf true` and `mkDefault` and a `metadata.region` under `mkDefault`, beside the kind's own plain `region`; the mixin's value is one more definition of the collection in the kind's priority pool, so the elements resolve as a `listOf` option's do, the kind's `region` wins, and a mixin's string `classes` is a catchable refusal by name";
}
