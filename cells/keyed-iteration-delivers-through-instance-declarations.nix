# `keyed-iteration-delivers-through-instance-declarations`, den-hoag-rulesof-fold-w9vlp. Red at a
# gen-program before `instanceDeclarations` (the export is missing). It would also go red if an
# item's identity came from its position (the insertion moves `wool`), from its value (the two silk
# bolts collapse into one firing), or if the list iteration delivered instead of being refused.
{ asserts, kidiRead }:
{
  construct = [ "keyed-iteration-delivers-through-instance-declarations" ];
  check = asserts (
    kidiRead == {
      firings = 3;
      woolKeptUnderInsertion = true;
      equalThreadsFirings = 2;
      equalThreadsHeads = 1;
      delivered = true;
      listRefused = "policy-body/iterated-delivery-unkeyed";
    }
  );
}
