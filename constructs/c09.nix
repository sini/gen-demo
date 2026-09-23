# ── C9 — a SHARE class over declared content (ADR-0028): the class partitions on `weave`,
# never on the kind boundary itself.
{ genClass, lib }:
let
  shareProjections = {
    pewter = {
      weave = "plain";
      spool = "linen";
    };
    damask = {
      weave = "plain";
      spool = "sateen";
    };
    grosgrain = {
      weave = "twill";
      gauge = "fine";
    };
    faille = {
      weave = "twill";
      gauge = "coarse";
    };
  };
  shareClasses = genClass.mkClasses {
    nodes = shareProjections;
    keyOf = _name: p: p.weave;
  };
  plainClass = lib.findFirst (c: c.key == "plain") null shareClasses;
  plainCore = genClass.mkCore {
    class = plainClass;
    projection = "selvage";
    projections = shareProjections;
  };
  pewterShared = genClass.applyCoreMerge {
    core = plainCore;
    memberProjection = shareProjections.pewter;
  };
  plainGate = genClass.gateCore {
    core = plainCore;
    candidate = pewterShared;
    real = shareProjections.pewter;
  };
  plainInvariance = genClass.invariantUnder {
    projection = "selvage";
    projections = shareProjections;
    class = plainClass;
  };
in
{
  inherit
    shareProjections
    shareClasses
    plainClass
    plainCore
    pewterShared
    plainGate
    plainInvariance
    ;
}
