# `declaration-of-resolves-both-forms` — C87, den-hoag-2zjg1. A `lacet`'s `tip`, written as the
# identifier "gilt" and as the `gilt` declaration itself, resolves to the one registry instance
# either way; its `spares` set, written `gilt horn gilt`, deduplicates by identity in first-seen
# order; its `cords` (`attrsOf`), written `a = "gilt"` and `b = <the gilt declaration>`, resolves both
# keys to that one instance (den-hoag-4tgvb); and the field's type reads `declarationOf(aglet)`. A
# gen-schema that resolved only one written form reds the first half, one whose set kept the duplicate
# reds the second, one whose binding does not walk `attrsOf` aborts the evaluation at `cords`, and one
# that still named the constructor `ref` reds the last.
{
  asserts,
  c87Aglets,
  c87Lacets,
  c87TipType,
}:
{
  construct = [ "field-holding-a-declaration-written-either-way" ];
  check = asserts (
    c87Lacets.byName.tip.id_hash == c87Aglets.gilt.id_hash
    && c87Lacets.byValue.tip.id_hash == c87Aglets.gilt.id_hash
    &&
      map (a: a.name) c87Lacets.byName.spares == [
        "gilt"
        "horn"
      ]
    && c87Lacets.byName.cords.a.id_hash == c87Aglets.gilt.id_hash
    && c87Lacets.byName.cords.b.id_hash == c87Aglets.gilt.id_hash
    && c87TipType.name == "declarationOf(aglet)"
  );
}
