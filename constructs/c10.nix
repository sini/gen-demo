# ── C10 — one stratified dispatch over an invented action family (ADR-0019): each rule's
# stratum is STAMPED by `deriveGroup` from its own declared `produces`, none written by hand.
{ genDispatch }:
let
  seamActions = genDispatch.mkActions {
    basting = [
      "tack"
      "gather"
    ];
    finishing = [ "hem" ];
  };
  seamRules = map (genDispatch.deriveGroup seamActions.groupOfKind) [
    (genDispatch.mkRule {
      identity = "tack-the-thimbles";
      produces = [ "tack" ];
      condition = {
        spool = "linen";
      };
      produce = id: _: [ (seamActions.tack { node = id; }) ];
    })
    (genDispatch.mkRule {
      identity = "hem-the-linen";
      produces = [ "hem" ];
      condition = {
        spool = "linen";
      };
      produce = id: _: [ (seamActions.hem { node = id; }) ];
    })
    (genDispatch.mkRule {
      identity = "gather-the-sateen";
      produces = [ "gather" ];
      condition = {
        spool = "sateen";
      };
      produce = id: _: [ (seamActions.gather { node = id; }) ];
    })
  ];
  seamDispatched = genDispatch.dispatch {
    rules = seamRules;
    id = "pewter";
    context = {
      spool = "linen";
    };
    match =
      cond: _id: ctx:
      cond.spool == ctx.spool;
    classify = seamActions.classify;
    groupOrder = [
      "basting"
      "finishing"
    ];
  };
in
{
  inherit seamActions seamRules seamDispatched;
}
