# `declaration-of-unbound-refused` — C87, den-hoag-registry-types-outside-kind-d24lq. The C87 types,
# declared on plain options that no registry binds: `tip` given the identifier "gilt", and `spares`
# given `gilt gilt`, and `cords` (an `attrsOf`) given `a = "gilt"`. With no binding there is no scope to resolve a reference in, so each is refused
# catchably rather than served as the raw identifier and the undeduplicated list. A gen-schema that
# still passed an unbound value through reds both halves; `declaration-of-resolves-both-forms` is the
# bound control. The refusal's text is read by T5 row 142.
{
  asserts,
  c87Unbound,
}:
let
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
in
{
  construct = [ "C87" ];
  check = asserts (refused c87Unbound.tip && refused c87Unbound.spares && refused c87Unbound.cords);
}
