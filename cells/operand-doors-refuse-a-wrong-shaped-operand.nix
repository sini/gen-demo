# `operand-doors-refuse-a-wrong-shaped-operand` — C179 (provisional), den-hoag-l3cwb. gen-program's
# `ruleEdges` over a non-model, `adjudicate` over a solved record with an integer atom, and
# `groundInstances` with a non-function `door` are each refused at the door; the same calls over
# well-formed operands answer. What each refusal SAYS is refusals row 146.

{
  asserts,
  c179Refused,
  c179OptionCode,
  c179Control,
}:

{
  construct = [ "C179" ];
  check = asserts (
    c179Refused == {
      ruleEdgesNonModel = true;
      adjudicateIntegerAtom = true;
    }
    && c179OptionCode == "policy-body/option-malformed"
    &&
      c179Control.edges == [
        {
          from = "x";
          label = "e";
          to = "y";
        }
      ]
    && c179Control.outcome == "admitted"
    && c179Control.ground == [ ]
  );
}
