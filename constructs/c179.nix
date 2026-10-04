# ── C179 (provisional) — gen-program's operand doors refuse a wrong-shaped operand by name
# (den-hoag-l3cwb). `ruleEdges` over a model that is not a gen-program result record, `adjudicate`
# over a solved record whose atom list holds an integer, and `groundInstances` with a malformed
# option are each refused catchably, where each aborted past `tryEval` or answered silently. The
# control is the same three calls over well-formed operands.
{
  genProgram,
  genScope,
}:
let
  refused = v: !(builtins.tryEval (builtins.deepSeq v true)).success;
  frozen = [
    "x"
    "y"
  ];
  decls = [
    {
      head = "a";
      relata = frozen;
      label = "e";
    }
  ];
  prog = genProgram.program frozen decls;
  mdl = genProgram.model {
    program = prog;
    interpretation = [ ];
    complete = true;
    prior = null;
  };
  solved = genScope.solve [ ] prog;
  adjudicateAt =
    model:
    (genProgram.adjudicate {
      program = prog;
      inherit model;
      interpretation = [ ];
    }).outcome;
  body = genProgram.body {
    name = "operand-doors";
    declared = [ ];
    clauses = [ ];
  };
in
{
  c179Refused = {
    ruleEdgesNonModel = refused (genProgram.ruleEdges 5 decls).reached;
    adjudicateIntegerAtom = refused (adjudicateAt (solved // { trueAtoms = [ 5 ]; }));
  };
  # `groundInstances` answers its refusals as tagged values, so the option's refusal is read as one.
  c179OptionCode = (genProgram.groundInstances { door = 5; } { } body).code;
  c179Control = {
    edges = (genProgram.ruleEdges mdl decls).reached;
    outcome = adjudicateAt solved;
    ground = genProgram.groundInstances { sources = { }; } { } body;
  };
}
