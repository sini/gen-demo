# `seam-promotion-is-minted` — C5, den-hoag-2quxu. C5's promoted seam head is a node the ONE mint
# made, never one keyed by hand: its identity is `hashIdentity` over the relata's MINTED identities,
# read off C3's own mint of those relata (ADR-0016 rulings 4 and 5). The control is the same hash
# over the relata's IDENTIFIERS, the constructed identity the promotion exists to refuse; it must
# differ, or the equality says nothing. This cell does not see the verdict: an OFF seam head is
# `gate-candidate-cycle-off`'s conjunct (`seamPromotion.nodes == { }`).
{
  asserts,
  inputs,
  minted,
  seamCoords,
  seamHead,
  seamPromotion,
}:
let
  inherit (inputs.gen.lib.substrate.identity) hashIdentity;
  keys = [ "identifier" ] ++ builtins.attrNames seamCoords;
  over = value: l: if l == "identifier" then seamHead else value seamCoords.${l};
  expected = hashIdentity "seam" keys (over (id: minted.nodes.${id}.identity));
  constructed = hashIdentity "seam" keys (over (id: id));
  node = seamPromotion.nodes.${seamHead};
in
{
  construct = [ "policy-program" ];
  check = asserts (
    builtins.attrNames seamPromotion.nodes == [ seamHead ]
    && node ? identity
    && node.identity == expected
    # control: an identity built from the relata's identifiers is a different value
    && constructed != expected
  );
}
