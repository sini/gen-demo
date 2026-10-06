# `corpus-stamp-relocation-invariant` — C21, den-hoag-ppv0z, den-hoag-cxlc0. A `thimble` composed
# the DEPRECATED way (`imports = [ config.schema.hank ]`, read live off the tree being declared) is
# read by gen-schema as `inherits = [ "hank" ]`, so it IS the `thimble` composed the RELOCATED way
# (`inherits = [ "hank" ]`, resolved by gen-schema's staged `evalSchema` pass), over the corpus's
# real instrument — gen-aspects' own `schemaOption`, `mkInstanceRegistry`, and C17's
# `extraModules` inlet: same `inherits`, same kind mark, same instance `id_hash` over one
# `_identityKeys` set. The relocated instance carries `hank`'s identity-bearing `selvage` and the
# no-inherit one does not, so the equality is between two arms that DO compose, not two that
# compose nothing. Relational, never a literal digest.
#
# DRIVEN RED: gen-schema before den-hoag-cxlc0 composes the head arm WITHOUT the name (`inherits`
# `[ ]`, another mark), which reds the equality; gen-schema at the refusal refuses the head arm;
# seeding `evalSchema` so `parentsOf` returns `[ ]` reds the `selvage` conjunct.
{
  asserts,
  c21HeadKind,
  c21RelocatedKind,
  c21HeadInstance,
  c21RelocatedInstance,
  c21NoInheritInstance,
}:
{
  construct = [ "relocation-its-deprecated-spelling-aliased" ];
  check = asserts (
    c21HeadKind.inherits == c21RelocatedKind.inherits
    && c21HeadKind.__mint.minted == c21RelocatedKind.__mint.minted
    && c21HeadInstance.id_hash == c21RelocatedInstance.id_hash
    && c21HeadInstance._identityKeys == c21RelocatedInstance._identityKeys
    && builtins.elem "selvage" c21RelocatedInstance._identityKeys
    && !(builtins.elem "selvage" c21NoInheritInstance._identityKeys)
  );
}
