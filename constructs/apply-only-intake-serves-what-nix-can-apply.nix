# ── C153 — an apply-only intake serves what Nix can apply (den-hoag-k0whn). One edge check, handed
# to gen-bind's `contract`, which applies it and never reads its formals.
{ genBind }:
{
  isSelvage = edge: edge == "selvage";
  edgeChecked = check: genBind.contract.apply (genBind.contract.mk { } check) "selvage" null;
}
