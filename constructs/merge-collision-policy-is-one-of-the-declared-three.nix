# ── C158 — a merge-collision policy outside the declared three is refused by name (den-hoag-d65u4).
# One binding, `spool`, collides with a module-system arg of the same name, and gen-bind's
# `mkMergeValidator` reads the caller's policy for it.
{ genBind }:
{
  policyAtSpoolCollision =
    policy:
    (genBind.mkMergeValidator {
      resolvePolicy = _: policy;
      boundArgNames = [ "spool" ];
      provenance = { };
    } { config._module.args.spool = "linen"; }).warnings;
}
