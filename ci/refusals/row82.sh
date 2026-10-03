# shellcheck shell=bash
# ── row 82 -- a sealed-only kind collision, refused by name (C64 `kind-mark-regime-tags`,
#    den-hoag-markof-partial-preimage-znfjq, (c+); ADR-0034) ──
# Two `selvage` kinds differing only in a refinement predicate (a caller lambda, so the field is
# sealed) under one message (the message is inert content and enters the mark) mint ONE mark. `kindEq` refuses the pair by name, naming the kind and the field and
# pointing at migration to a first-order term. The unplanted arm compares the kind with itself.
row82='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  selvage = r: (merge.evalModuleTree { modules = [
    { options.schema = schema.mkSchemaOption { }; }
    { config.schema.selvage.options.ends = merge.mkOption { type = schema.refined merge.types.int r; }; }
  ]; }).config.schema.selvage;
  inRange = check: { inherit check; message = "must be in range"; };
  tcpLike = inRange (v: v > 0 && v < 65536);
  posLike = inRange (v: v > 0);
  ends = selvage tcpLike;
in BODY'
check "T5 row82 unplanted (a kind compared with itself is one kind)" \
  "${row82/BODY/builtins.toJSON (schema.kindEq ends ends)}" 0 "" \
  "$tmpdir/row82-green.err" 'true'
check "T5 row82 planted   (two kinds differing only at a sealed field, refused by name)" \
  "${row82/BODY/builtins.toJSON (schema.kindEq ends (selvage posLike))}" 1 \
  "gen-schema: kindEq: two declarations of 'selvage' mint one identity and are unequal only at sealed component(s) 'options.ends.type'" \
  "$tmpdir/row82-red.err"
check "T5 row82 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row82/BODY/if (builtins.tryEval (schema.kindEq ends (selvage posLike))).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row82-catch.err" 'CAUGHT'
