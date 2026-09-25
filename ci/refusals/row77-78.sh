# shellcheck shell=bash
# ── rows 77/78 -- the intensional encoder's two throw-refusals (C56 `identity-regimes`,
#    den-hoag-3f39; ADR-0034) ──
# Row 77: a registry's `revision` is REQUIRED and TOTAL -- two registries with one member set and
# different builder bodies are indistinguishable to every builtin, so the declared revision is the
# only term that separates them, and a registry without one is refused at construction rather than
# defaulted. Row 78: a lambda in `args` is ADR-0034's excluded population -- its collapse is replaced
# by a refusal, never by a structural identity -- so demanding the mint refuses by name. Both reach
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
  mk = genAlgebra.mkIntensional gen.lib.substrate.identity.hashIdentity { revision = "r1"; members.whipstitch = args: (x: x); };
  v = mk "whipstitch" { thread = THREAD; };
  minted = (genAlgebra.identityOf v).minted;
in BODY'
row78unplanted="${row78/THREAD/\"madder\"}"
row78planted="${row78/THREAD/x: x}"
check "T5 row78 unplanted (inert args mint an identity; that it is a string is the answer)" \
  "${row78unplanted/BODY/builtins.toJSON (builtins.isString minted)}" 0 "" \
  "$tmpdir/row78-green.err" 'true'
check "T5 row78 planted   (a lambda in args, refused by name when the identity is demanded)" \
  "${row78planted/BODY/builtins.toJSON (builtins.isString minted)}" 1 \
  "identity: a lambda in an identity position" \
  "$tmpdir/row78-red.err"
check "T5 row78 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row78planted/BODY/if (builtins.tryEval minted).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row78-catch.err" 'CAUGHT'
