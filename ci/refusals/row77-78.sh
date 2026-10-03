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
row77='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAlgebra = gen.lib.substrate.algebra;
  v = genAlgebra.mkIntensional gen.lib.substrate.identity.hashIdentity REGISTRY "whipstitch" { thread = "madder"; };
in BODY'
row77unplant='{ revision = "r1"; members.whipstitch = args: (x: x); }'
row77plant='{ members.whipstitch = args: (x: x); }'
row77unplanted="${row77/REGISTRY/$row77unplant}"
row77planted="${row77/REGISTRY/$row77plant}"
check "T5 row77 unplanted (a registry declaring its revision; the program point is the answer)" \
  "${row77unplanted/BODY/v.name}" 0 "" \
  "$tmpdir/row77-green.err" 'whipstitch'
check "T5 row77 planted   (a registry declaring no revision, refused by name at construction)" \
  "${row77planted/BODY/v.name}" 1 \
  "intensional: registry declares no revision" \
  "$tmpdir/row77-red.err"
check "T5 row77 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row77planted/BODY/if (builtins.tryEval v.name).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row77-catch.err" 'CAUGHT'
row78='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAlgebra = gen.lib.substrate.algebra;
  T = gen.lib.modules.merge.types;
  mk = genAlgebra.mkIntensional gen.lib.substrate.identity.hashIdentity { revision = "r1"; members.whipstitch = args: (x: x); };
  twice = T.typeEq (T.typedef "stitched" (mk "whipstitch" { thread = THREAD; })) (T.typedef "stitched" (mk "whipstitch" { thread = THREAD; }));
in BODY'
row78unplanted="${row78//THREAD/\"madder\"}"
row78planted="${row78//THREAD/x: x}"
check "T5 row78 unplanted (inert args: two constructions of one term are one type; that it is true is the answer)" \
  "${row78unplanted/BODY/builtins.toJSON twice}" 0 "" \
  "$tmpdir/row78-green.err" 'true'
check "T5 row78 planted   (a lambda in args: two constructions are refused by name, never decided)" \
  "${row78planted/BODY/builtins.toJSON twice}" 1 \
  "gen-types: typeEq: two declarations of 'stitched' mint one identity and are unequal only at sealed component(s) 'pred'" \
  "$tmpdir/row78-red.err"
check "T5 row78 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row78planted/BODY/if (builtins.tryEval twice).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row78-catch.err" 'CAUGHT'
