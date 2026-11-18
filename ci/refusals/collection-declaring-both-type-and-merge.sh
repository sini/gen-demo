# shellcheck shell=bash
# ── a collection declaring both `type` and a custom `merge` is refused BY NAME, catchably
#    (den-hoag-collection-declared-element-type-fwjez; gen-schema's declared collection type) ──
# A declared type merges its own definitions, so a `merge` beside it would be a second fold of the
# same definitions; gen-schema refuses the pair rather than choosing one silently. The unplanted arm
# declares the type alone and asserts a STDOUT VALUE, so a schema refusing every typed collection
# cannot pass it; the planted arm adds the `merge` and must be refused by name.
row_collection_declaring_both_type_and_merge='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  T = genMerge.types;
  read = coll: builtins.toJSON (genMerge.evalModuleTree { } [
    { options.schema = genSchema.mkSchemaOption { collections.classes = coll; }; }
    { config.schema.user.classes = [ "darwin" ]; }
  ]).config.schema.user.classes;
  typed = { default = [ ]; type = T.listOf T.str; };
  both = typed // { merge = a: b: a ++ b; };
in BODY'
check "T5 collection-declaring-both-type-and-merge unplanted (a collection declaring its type alone resolves through it)" \
  "${row_collection_declaring_both_type_and_merge/BODY/read typed}" 0 "" "$tmpdir/collection-declaring-both-type-and-merge-green.err" '["darwin"]'
check "T5 collection-declaring-both-type-and-merge planted   (the same collection with a custom merge beside its type is refused by name)" \
  "${row_collection_declaring_both_type_and_merge/BODY/read both}" 1 \
  "gen-schema: collection 'classes' declares both \`type\` and \`merge\`; a declared type merges its own definitions, so declare one of them" \
  "$tmpdir/collection-declaring-both-type-and-merge-red.err"
check "T5 collection-declaring-both-type-and-merge catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_collection_declaring_both_type_and_merge/BODY/if (builtins.tryEval (builtins.deepSeq (read both) null)).success then \"ADMITTED\" else \"CAUGHT\"}" \
  0 "" "$tmpdir/collection-declaring-both-type-and-merge-catch.err" 'CAUGHT'
