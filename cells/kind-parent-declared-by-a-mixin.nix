# `kind-parent-declared-by-a-mixin`. A parent a mixin declares is a parent of the kind at every
# reader of `inherits`: `host`'s `ancestorsForKind` names `audited`, as its kind-written twin's does,
# the first ancestor is the `audited` kind value (`kindEq`), and `host` composes `audited`'s option
# exactly as the twin does. Red when the walk reads the kind's own `inherits` only (ancestors `[ ]`,
# options `[ hostName ]`).

{
  asserts,
  genSchema,
  auditedKind,
  hostByMixinParent,
  hostByKindParent,
}:

let
  names = k: map (a: a.kind) (genSchema.ancestorsForKind k);
  opts = k: builtins.attrNames k.options;
in

{
  construct = [ "kind-parent-declared-by-a-mixin" ];
  check = asserts (
    names hostByMixinParent.host == [ "audited" ]
    && names hostByMixinParent.host == names hostByKindParent.host
    && opts hostByMixinParent.host == opts hostByKindParent.host
    && genSchema.kindEq (builtins.head (genSchema.ancestorsForKind hostByMixinParent.host)) auditedKind
  );
}
