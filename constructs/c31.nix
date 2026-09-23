# ── den-hoag-cr72 — gen-aspects' custom guard-form vocabulary refuses EAGERLY. A malformed
# or core-colliding `cnf.guardForms` entry used to construct fine and refuse only when that
# exact form was dispatched BY NAME, so the library's own "MUST be { eval; reads; }" held for
# exactly the forms a run happened to look up. `fourchette` is an invented (unused) fabric
# term, per the corpus's naming rule; `eq` below is not corpus vocabulary but the NAME OF A
# CORE PREDICATE FORM in gen-aspects, which is the collision under test.
{ roster }:
let
  cr72Vocab = forms: roster.aspects.mkGuardVocab { guardForms = forms; };
  cr72Sound = {
    eval = _ctx: _a: true;
    reads = [ ];
  };
  cr72NoReads = {
    eval = _ctx: _a: true;
  };
  # Dispatch through an unrelated CORE predicate: nothing in this call names any declared
  # custom form, which is the defect at full strength.
  cr72Dispatch = gv: gv.applyGuard { yardage = 3; } (gv.vocab.always { fired = true; });
  # deepSeq, not WHNF: a refusal living in a lazy attribute value is invisible to a bare tryEval.
  cr72Refuses = e: !(builtins.tryEval (builtins.deepSeq e true)).success;
  cr72Constructs = v: (builtins.tryEval (builtins.deepSeq v true)).success;
in
{
  inherit
    cr72Vocab
    cr72Sound
    cr72NoReads
    cr72Dispatch
    cr72Refuses
    cr72Constructs
    ;
}
