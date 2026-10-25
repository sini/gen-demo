{
  title = "a computed field reads a collection a mixin contributes to";
  adr = "0039, 0013";
  what = "`computed-field-reads-a-mixin-collection`: a schema mixin contributes `tags` to `host` beside its own, and the schema's `computed` hook reads the collection back; `host`'s computed `tagged` equals its published `tags`, the mixin's value included, and equals the twin's whose kind writes the value itself";
}
