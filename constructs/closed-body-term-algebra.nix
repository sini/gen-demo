# ── C14 — the closed, first-order body-term algebra (ADR-0013 table row 2, ADR-0023). A
# TargetId is LITERAL in the term, so no term can compute which fixpoint to read.
{ genBind }:
let
  selvageTerm =
    with genBind.crossing.term;
    concat [
      (lit "selvage-")
      (readFrom "pewter" [ "spool" ])
    ];
  selvageEnv = {
    targets.pewter = {
      spool = "linen";
    };
    siblings = { };
  };
  selvageChecked = genBind.crossing.checkTerm selvageTerm;
  selvageResolved = genBind.crossing.resolveTerm selvageEnv selvageTerm;
  knownFormers = genBind.crossing.knownFormers;
  crossingPrims = genBind.crossing.prims;
  inertBudget = genBind.crossing.inertBudget;
  readCtxHeadsOfSelvage = genBind.crossing.readCtxHeads selvageTerm;
  # THE THREE REFUSAL ARMS — refusals are DATA (a `__crossingResult == "refusal"` record),
  # never a throw, so all three are `checks` cells here rather than `refusals` rows.
  selvageBadLitChecked = genBind.crossing.checkTerm (
    with genBind.crossing.term; lit { spool = _: "linen"; }
  );
  selvageBadReadFromResolved = genBind.crossing.resolveTerm selvageEnv (
    with genBind.crossing.term; readFrom "sarcenet" [ "spool" ]
  );
  selvageBadVocabChecked = genBind.crossing.checkTerm { __bodyTerm = "Frobnicate"; };
in
{
  inherit
    selvageTerm
    selvageEnv
    selvageChecked
    selvageResolved
    knownFormers
    crossingPrims
    inertBudget
    readCtxHeadsOfSelvage
    selvageBadLitChecked
    selvageBadReadFromResolved
    selvageBadVocabChecked
    ;
}
