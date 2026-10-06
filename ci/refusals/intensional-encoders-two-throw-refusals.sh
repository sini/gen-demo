# shellcheck shell=bash
# ── rows 77/78 -- the intensional encoder's two throw-refusals (C56 `identity-regimes`,
#    den-hoag-3f39; ADR-0034) ──
# Row 77: a registry's `revision` is REQUIRED and TOTAL -- two registries with one member set and
# different builder bodies are indistinguishable to every builtin, so the declared revision is the
# only term that separates them, and a registry without one is refused at construction rather than
# defaulted. Row 78: a lambda in `args` is ADR-0034's excluded population -- its collapse is replaced
# by a refusal, never by a structural identity. A registered construction is compared by its declared
# subject and never minted (den-hoag-6orb8 U1), so the refusal lands where two constructions are
# compared: two `typedef`s over the term are refused by name, where inert args decide one type. Both reach
# the encoder through the hub's `genAlgebra` with the hub's one mint injected. Each unplanted arm is
# the same construction with the plant removed, and asserts the answer; the catchable arm is row
# 33's form.
row_intensional_encoders_two_throw_refusals='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAlgebra = gen.lib.substrate.algebra;
  v = genAlgebra.mkIntensional gen.lib.substrate.identity.hashIdentity REGISTRY "whipstitch" { thread = "madder"; };
in BODY'
row_intensional_encoders_two_throw_refusalsunplant='{ revision = "r1"; members.whipstitch = args: (x: x); }'
row_intensional_encoders_two_throw_refusalsplant='{ members.whipstitch = args: (x: x); }'
row_intensional_encoders_two_throw_refusalsunplanted="${row_intensional_encoders_two_throw_refusals/REGISTRY/$row_intensional_encoders_two_throw_refusalsunplant}"
row_intensional_encoders_two_throw_refusalsplanted="${row_intensional_encoders_two_throw_refusals/REGISTRY/$row_intensional_encoders_two_throw_refusalsplant}"
check "T5 intensional-encoders-two-throw-refusals unplanted (a registry declaring its revision; the program point is the answer)" \
  "${row_intensional_encoders_two_throw_refusalsunplanted/BODY/v.name}" 0 "" \
  "$tmpdir/intensional-encoders-two-throw-refusals-green.err" 'whipstitch'
check "T5 intensional-encoders-two-throw-refusals planted   (a registry declaring no revision, refused by name at construction)" \
  "${row_intensional_encoders_two_throw_refusalsplanted/BODY/v.name}" 1 \
  "intensional: registry declares no revision" \
  "$tmpdir/intensional-encoders-two-throw-refusals-red.err"
check "T5 intensional-encoders-two-throw-refusals catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_intensional_encoders_two_throw_refusalsplanted/BODY/if (builtins.tryEval v.name).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/intensional-encoders-two-throw-refusals-catch.err" 'CAUGHT'
row_inert_args='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAlgebra = gen.lib.substrate.algebra;
  T = gen.lib.modules.merge.types;
  mk = genAlgebra.mkIntensional gen.lib.substrate.identity.hashIdentity { revision = "r1"; members.whipstitch = args: (x: x); };
  twice = T.typeEq (T.typedef "stitched" (mk "whipstitch" { thread = THREAD; })) (T.typedef "stitched" (mk "whipstitch" { thread = THREAD; }));
in BODY'
row_inert_argsunplanted="${row_inert_args//THREAD/\"madder\"}"
row_inert_argsplanted="${row_inert_args//THREAD/x: x}"
check "T5 inert-args unplanted (inert args: two constructions of one term are one type; that it is true is the answer)" \
  "${row_inert_argsunplanted/BODY/builtins.toJSON twice}" 0 "" \
  "$tmpdir/inert-args-green.err" 'true'
check "T5 inert-args planted   (a lambda in args: two constructions are refused by name, never decided)" \
  "${row_inert_argsplanted/BODY/builtins.toJSON twice}" 1 \
  "gen-types: typeEq: two declarations of 'stitched' mint one identity and are unequal only at sealed component(s) 'pred'" \
  "$tmpdir/inert-args-red.err"
check "T5 inert-args catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_inert_argsplanted/BODY/if (builtins.tryEval twice).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/inert-args-catch.err" 'CAUGHT'
