# den-hoag-s1ua7 / den-hoag-3nr2o: guard bodies whose data is shaped like a refusal or a term, placed
# at an aspect position through the hub's gen-aspects and fired at `{ }`.
{
  genAspects,
  c141Place,
}:
let
  gv = genAspects.mkGuardVocab { };
  fired = b: gv.applyGuard { } (c141Place { } { d = genAspects.guard genAspects.pred.always b; }).d;
  caught = b: !(builtins.tryEval (builtins.deepSeq (fired b) true)).success;
in
{
  s1ua7LeftData = fired { l.left = 1; };
  s1ua7Refused = {
    refusalShape = caught {
      l.left = {
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
