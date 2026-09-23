# `seam-identity-collision-refused` — C27. Two intensional functions sharing the program-point name
# `notchGuard` (ADR-0034, den-hoag-t6iy2): the substrate mints no handle from that name, so neither
# rule collapses onto the other's `overridden` entry; the no-override arm still fires both, and
# overriding either one now throws `compose.nix`'s existing "cannot override anonymous rule" refusal
# by name instead of silently replacing whichever rule the substrate saw last.
#
# C27 — gen-dispatch's rule-identity keying refuses a collision rather than
# silently overriding the wrong rule: two intensional functions sharing the
# program-point name `notchGuard` derive no handle at all (a name-only key is
# never minted), the no-override arm still fires both, and an override attempt
# against either one throws `compose.nix`'s named refusal.
{
  asserts,
  notchNoOverride,
  notchOverrideRefuses,
  notchRuleA,
  notchRuleB,
}:
{
  construct = [ "C27" ];
  check = asserts (
    notchRuleA.identity == null
    && notchRuleB.identity == null
    &&
      notchNoOverride == [
        {
          __action = "notch";
          side = "basting";
        }
        {
          __action = "notch";
          side = "finishing";
        }
      ]
    && notchOverrideRefuses
  );
}
