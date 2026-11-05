# `terminal-less-class-refused` — C106, den-hoag-xtrxn. `bobbinet`'s `sashiko` content addresses a
# class with no terminal: reading the realized `crewel` set refuses, catchably, where it used to
# return crewel's artifact with sashiko's content silently gone. The control realizes the same
# projection with a terminal for every content class, so the refusal is sashiko's and not the
# fixture's.
{ asserts, undeliveredRealized, deliveredRealized }:
let
  forces = v: (builtins.tryEval (builtins.deepSeq v v)).success;
in
{
  construct = [ "C106" ];
  check = asserts (
    !(forces undeliveredRealized.crewel)
    && deliveredRealized.sashiko.bobbinet.modules == [ { stitch = "sashiko"; } ]
    && deliveredRealized.crewel.bobbinet.modules == [ { stitch = "crewel"; } ]
  );
}
