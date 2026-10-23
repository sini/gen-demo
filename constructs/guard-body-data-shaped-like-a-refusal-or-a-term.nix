# den-hoag-s1ua7 / den-hoag-3nr2o: guard bodies whose data is shaped like a refusal or a term, placed
# at an aspect position through the hub's gen-aspects and fired at `{ }`. The data rides under `welt`, a
# declared channel: an undeclared nested key holding a scalar is an orphan leaf in a guard body as in a
# static one.
{
  genAspects,
  c141Place,
}:
let
  gv = genAspects.mkGuardVocab { };
  fired =
    b:
    gv.applyGuard { }
      (c141Place { keySemantics.welt.category = "channel"; } {
        d = genAspects.guard genAspects.pred.always b;
      }).d;
  caught = b: !(builtins.tryEval (builtins.deepSeq (fired b) true)).success;
in
{
  s1ua7LeftData = fired { welt.l.left = 1; };
  s1ua7Refused = {
    refusalShape = caught {
      welt.l.left = {
        code = "bogus";
        witness = { };
      };
    };
    handSpelledTerm = caught {
      x = {
        __bodyTerm = "Lit";
        value = 1;
      };
    };
  };
}
