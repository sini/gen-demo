# shellcheck shell=bash
# ── row 148 -- a wrong-shaped operand of a gen-program door is refused BY NAME, stating the operand and
#    the form expected (den-hoag-l3cwb; C184) ──
# `ruleEdges` reads its model only where a labelled declaration reaches it, `adjudicate` reads the atom
# lists of its solved record, and both aborted with the evaluator's own text (or answered silently).
# The unplanted arm answers over well-formed operands and asserts a STDOUT VALUE.
row148='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  program = gen.lib.framework.program;
  scope = gen.lib.substrate.scope;
  frozen = [ "x" "y" ];
  decls = [ { head = "a"; relata = frozen; label = "e"; } ];
  prog = program.program frozen decls;
  mdl = program.model { program = prog; interpretation = [ ]; complete = true; prior = null; };
  solved = scope.solve [ ] prog;
  adjudicateAt = model: (program.adjudicate { program = prog; inherit model; interpretation = [ ]; }).outcome;
  green = (builtins.head (program.ruleEdges mdl decls).reached).label + "/" + adjudicateAt solved;
  modelRed = builtins.deepSeq (program.ruleEdges 5 decls).reached "admitted";
  atomRed = builtins.deepSeq (adjudicateAt (solved // { trueAtoms = [ 5 ]; })) "admitted";
  caught = if (builtins.tryEval (builtins.deepSeq (adjudicateAt (solved // { trueAtoms = [ 5 ]; })) true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row148 unplanted (well-formed operands answer: the edge label and the outcome)" \
  "${row148/BODY/green}" 0 "" "$tmpdir/row148-green.err" 'e/admitted'
check "T5 row148 planted   (ruleEdges over a non-attrset model is refused naming the operand and its form)" \
  "${row148/BODY/modelRed}" 1 \
  "gen-program.ruleEdges: the \`model\` operand (a gen-program result record): the argument must be an attrset, not a int" \
  "$tmpdir/row148-model.err"
check "T5 row148 planted   (adjudicate over an integer atom is refused naming the field and its form)" \
  "${row148/BODY/atomRed}" 1 \
  "gen-program.adjudicate: the \`model\` operand (a gen-scope solved record): field 'trueAtoms' must be a list of strings, not a list holding a int" \
  "$tmpdir/row148-atom.err"
check "T5 row148 catchable  (the integer-atom refusal is caught by tryEval, not an abort)" \
  "${row148/BODY/caught}" 0 "" "$tmpdir/row148-catch.err" 'CAUGHT'
