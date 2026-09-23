# `policy-edge` — C5. The policy program's stable model, total, and the derived edge admitted.
#
# C5 — the policy program's stable model, total, and the derived edge admitted.
{
  asserts,
  mdl,
  pipingHead,
}:
{
  construct = [ "C5" ];
  check = asserts (
    (mdl.resolve pipingHead).included == true
    && mdl.adjudication.outcome == "admitted"
    && mdl.adjudication.searched == false
    && mdl.adjudication.ground == "Van Gelder, Ross & Schlipf 1991, Corollary 5.6"
  );
}
