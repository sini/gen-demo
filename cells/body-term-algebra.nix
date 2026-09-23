# `body-term-algebra` — C14. The resolved term, `knownFormers`, the crossing's primitives and inert
# budget, and all three refusal arms as data — the one construct whose refusals live in this cell
# rather than in `refusals`.
#
# C14 — the closed, first-order body-term algebra: refusals are DATA, never a
# throw, so all three refusal arms live in this one cell rather than in
# `refusals` — the only construct of which that is true.
{
  asserts,
  crossingPrims,
  inertBudget,
  knownFormers,
  readCtxHeadsOfSelvage,
  selvageBadLitChecked,
  selvageBadReadFromResolved,
  selvageBadVocabChecked,
  selvageChecked,
  selvageResolved,
}:
{
  construct = [ "C14" ];
  check = asserts (
    selvageResolved == {
      __crossingResult = "ok";
      value = "selvage-linen";
    }
    && selvageChecked.__crossingResult == "ok"
    &&
      knownFormers == [
        "Lit"
        "ReadFrom"
        "ReadCtx"
        "If"
        "Attrs"
        "List"
        "Concat"
        "PathJoin"
        "Apply"
      ]
    &&
      builtins.attrNames crossingPrims == [
        "attrNames"
        "concatStringsSep"
        "elemAt"
        "getAttr"
        "length"
        "toString"
      ]
    &&
      inertBudget == {
        maxDepth = 32;
        maxNodes = 10000;
      }
    && readCtxHeadsOfSelvage == [ ]
    && selvageBadLitChecked.refusal.code == "lit-payload-function"
    && selvageBadLitChecked.refusal.blamed == "supplier"
    && selvageBadReadFromResolved.refusal.code == "readfrom-names-non-member"
    &&
      selvageBadReadFromResolved.refusal.witness == {
        available = [ "pewter" ];
        target = "sarcenet";
      }
    && selvageBadVocabChecked.refusal.code == "term-vocabulary"
    && selvageBadVocabChecked.refusal.witness.former == "Frobnicate"
  );
}
