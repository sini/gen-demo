{
  title = "a parent a mixin declares is a parent of the kind";
  adr = "0039, 0013";
  what = "`kind-parent-declared-by-a-mixin`: a schema mixin gives `host` the parent `audited`, a kind declared in another tree, and a twin tree declares the same parent on `host` itself; gen-schema's `ancestorsForKind` names `audited` for both, the first ancestor is the `audited` kind value, and `host` composes `audited`'s option exactly as its twin does";
}
