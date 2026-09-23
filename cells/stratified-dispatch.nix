# `stratified-dispatch` — C10. Each rule's stratum stamped by `deriveGroup`; the `sateen` rule not
# firing against a `linen` context is the discriminator.
#
# C10 — one stratified dispatch: each rule's stratum was STAMPED by
# `deriveGroup` from its own declared `produces`, none written by hand; the `sateen`
# rule not firing against a `linen` context is the discriminator.
{
  asserts,
  seamDispatched,
  seamRules,
}:
{
  construct = [ "C10" ];
  check = asserts (
    map (x: x.group) seamRules == [
      "basting"
      "finishing"
      "basting"
    ]
    &&
      seamDispatched.actions == {
        basting = [
          {
            __action = "tack";
            node = "pewter";
          }
        ];
        finishing = [
          {
            __action = "hem";
            node = "pewter";
          }
        ];
      }
    &&
      seamDispatched.orderedGroups == [
        "basting"
        "finishing"
      ]
  );
}
