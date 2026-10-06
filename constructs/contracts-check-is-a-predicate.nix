# ── C155 — a contract's check is a predicate (den-hoag-5rz5r). One edge verdict, handed to gen-bind's
# `contract`, which reads its result as a Boolean.
{ genBind }:
{
  edgeVerdict = check: genBind.contract.apply (genBind.contract.mk { } check) "selvage" null;
}
