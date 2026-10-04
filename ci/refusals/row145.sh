# shellcheck shell=bash
# ── row 145 -- a function `when` where the literal tier is required is refused BY NAME at gen-program's
#    `declaration`, and so is an `any` term (den-hoag-fuci G1; C177) ──
# C177 holds that den v1's `includeIf` guards, written as `when` terms, decide; tryEval cannot read which
# refusal a closure `when` raised, so the message is read here. v1's guard as written, a closure over
# `ctx`, has no body to lower; the unplanted arm carries a `has` term and asserts a STDOUT VALUE, the
# lowered declaration, so a door that refused every `when` cannot pass it.
row145='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProgram = gen.lib.framework.program;
  genAlgebra = gen.lib.substrate.algebra;
  t = (genAlgebra.term gen.lib.substrate.identity.hashIdentity).term;
  declareWhen = w: genProgram.declaration { when = w; } [ "bolt" ] "facing:bolt";
  lowered = builtins.toJSON (declareWhen (t.has "gusset-held:bolt"));
  closureRed = builtins.deepSeq (declareWhen (ctx: ctx.hasAspect "gusset")) "admitted";
  anyRed = builtins.deepSeq (declareWhen (t.any [ (t.has "godet-held:bolt") (t.has "gusset-held:bolt") ])) "admitted";
in BODY'
check "T5 row145 unplanted (a literal when lowers to the declaration pos/neg)" \
  "${row145/BODY/lowered}" 0 "" "$tmpdir/row145-green.err" \
  '{"head":"facing:bolt","label":null,"neg":[],"pos":["gusset-held:bolt"],"promote":null,"relata":["bolt"]}'
check "T5 row145 planted   (a closure when is refused by name: it crosses the gen-rules door)" \
  "${row145/BODY/closureRed}" 1 \
  "gen-program.declaration: \`when\` is not in the literal tier: a function \`when\` stays unlowerable" \
  "$tmpdir/row145-closure.err"
check "T5 row145 planted   (an any term is refused by name: one declaration per disjunct)" \
  "${row145/BODY/anyRed}" 1 \
  "\`any\` is a disjunction, and a rule body is a conjunction: write one declaration per disjunct over the one head" \
  "$tmpdir/row145-any.err"
