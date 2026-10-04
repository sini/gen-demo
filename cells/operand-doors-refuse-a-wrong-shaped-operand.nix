# `operand-doors-refuse-a-wrong-shaped-operand` — C184, den-hoag-l3cwb. gen-program's
# `ruleEdges` over a non-model, `adjudicate` over a solved record with an integer atom, and
# `groundInstances` with a non-function `door` are each refused at the door; the same calls over
# well-formed operands answer. What each refusal SAYS is refusals row 148.

{
  asserts,
  c184Refused,
  c184OptionCode,
  c184Control,
}:

{
  construct = [ "C184" ];
  check = asserts (
    c184Refused == {
      ruleEdgesNonModel = true;
      adjudicateIntegerAtom = true;
    }
    && c184OptionCode == "policy-body/option-malformed"
    &&
      c184Control.edges == [
        {
          from = "x";
          label = "e";
          to = "y";
        }
      ]
    && c184Control.outcome == "admitted"
    && c184Control.ground == [ ]
  );
}
