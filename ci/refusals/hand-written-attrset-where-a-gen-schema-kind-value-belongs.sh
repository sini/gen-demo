# shellcheck shell=bash
# ── rows 75/76 -- a HAND-WRITTEN attrset where a gen-schema KIND VALUE belongs, at both of
#    gen-select's kind-admission doors (ADR-0034, den-hoag-l0y) ──
# Row 8 already plants a bare kind-name STRING, which the shape guard always caught. These plant the
# value that guard ADMITTED: `{ kind = "thimble"; options = { }; }` satisfied `? kind && ? options`
# exactly, matched, and was indistinguishable from a real kind under `selectorEq` -- a
# provenance-shaped guard over a predicate that checked no provenance. What refuses it now is the
# mint-backed mark gen-schema stamps at construction.
# ★ The unplanted arm's kind value is minted through `mkSchemaOption` in the row's OWN tree, never
# imported from the corpus, so the plant cannot perturb the corpus's own declarations; and it
# asserts a STDOUT VALUE, so a library that refused everything cannot pass it.
# ★ TWO ROWS AND NOT ONE, because the two doors are different mechanisms: `sel.kind` refuses at
# construction, while `mkContext` seqs its `validatedKind` to WHNF and refuses at first use of the
# context. A single row would pin one and leave the other's message unread.
rowKindHeader='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSelect = gen.lib.substrate.select;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  tree = genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble = { options.spool = genMerge.mkOption { type = genMerge.types.str; default = "linen"; }; }; }
    ];
  minted = tree.config.schema.thimble;
  handWritten = { kind = "thimble"; options = { }; };
'
row_hand_written_attrset_where_a_gen_schema_kind_value_belongs="${rowKindHeader}"'in builtins.toJSON (genSelect.kind ARG).name'
check "T5 hand-written-attrset-where-a-gen-schema-kind-value-belongs unplanted (a schema-minted kind value carries the mark)" "${row_hand_written_attrset_where_a_gen_schema_kind_value_belongs/ARG/minted}" 0 "" \
  "$tmpdir/hand-written-attrset-where-a-gen-schema-kind-value-belongs-green.err" '"thimble"'
check "T5 hand-written-attrset-where-a-gen-schema-kind-value-belongs planted   (a hand-written attrset of the same shape, no mark)" "${row_hand_written_attrset_where_a_gen_schema_kind_value_belongs/ARG/handWritten}" 1 \
  "gen-select: sel.kind expects a gen-schema kind value carrying a mint-backed mark" \
  "$tmpdir/hand-written-attrset-where-a-gen-schema-kind-value-belongs-red.err"

row_same_minted_kind_builds_a_context_that_answers="${rowKindHeader}"'  ctx = k: genSelect.adapters.registry.mkContext {
    nodes = [ "pewter" ]; data = _: { }; parent = _: null; kind = k;
  };
in builtins.toJSON ((ctx ARG).children "pewter")'
check "T5 same-minted-kind-builds-a-context-that-answers unplanted (the same minted kind builds a context that answers)" "${row_same_minted_kind_builds_a_context_that_answers/ARG/minted}" 0 "" \
  "$tmpdir/same-minted-kind-builds-a-context-that-answers-green.err" '[]'
check "T5 same-minted-kind-builds-a-context-that-answers planted   (the same hand-written attrset, at the second door)" "${row_same_minted_kind_builds_a_context_that_answers/ARG/handWritten}" 1 \
  'gen-select: adapters.registry.mkContext `kind` expects a gen-schema kind value carrying a mint-backed mark' \
  "$tmpdir/same-minted-kind-builds-a-context-that-answers-red.err"
