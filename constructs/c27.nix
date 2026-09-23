# ── C27 — gen-dispatch's rule-identity keying refuses a collision (ADR-0034,
# den-hoag-t6iy2). Two intensional functions sharing one program-point NAME
# (`notchGuard`, bound twice below, each closing over a different tag) used to derive
# the SAME override handle from that name and collapse to one `overridden` entry, so
# overriding either one silently replaced whichever the substrate happened to see
# last. Neither rule mints a handle from `.name` now: both still dispatch with no
# override in play (the no-override arm is unaffected), and overriding either one
# refuses BY NAME — `compose.nix`'s existing "cannot override anonymous rule" throw —
# instead of retargeting the wrong rule.
{ genDispatch }:
let
  notchGuardA = {
    name = "notchGuard";
    closure = "bastingSide";
    __functor = self: _ctx: [
      {
        __action = "notch";
        side = "basting";
      }
    ];
  };
  notchGuardB = {
    name = "notchGuard";
    closure = "finishingSide";
    __functor = self: _ctx: [
      {
        __action = "notch";
        side = "finishing";
      }
    ];
  };
  notchRuleA = genDispatch.fromFunction notchGuardA;
  notchRuleB = genDispatch.fromFunction notchGuardB;
  notchReplacement = genDispatch.mkRule {
    condition = { };
    produce = _id: _ctx: [
      {
        __action = "notch";
        side = "usurped";
      }
    ];
    identity = "notch-replacement";
  };
  notchDispatch =
    rules:
    genDispatch.dispatch {
      inherit rules;
      id = null;
      context = { };
      match =
        _cond: _id: _ctx:
        true;
      classify = _a: "notch";
      groupOrder = [ "notch" ];
    };
  notchNoOverride =
    (notchDispatch [
      notchRuleA
      notchRuleB
    ]).actions.notch;
  notchOverrideRefuses =
    !(builtins.tryEval (genDispatch.override notchRuleA notchReplacement)).success;
in
{
  inherit
    notchGuardA
    notchGuardB
    notchRuleA
    notchRuleB
    notchReplacement
    notchDispatch
    notchNoOverride
    notchOverrideRefuses
    ;
}
