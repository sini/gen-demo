# shellcheck shell=bash
# ── a collection declaring a field outside its closed set is refused BY NAME, catchably
#    (den-hoag-collection-declared-element-type-fwjez; gen-schema's closed collection field set) ──
# A collection's declaration takes `default`, `identity`, `merge` and `type`, and nothing else. A
# misspelt field was once served silently (the collection read as if the field were absent); it is
# now refused through the shared closed-options check, naming the door and the collection. The
# unplanted arm declares only known fields and asserts a STDOUT VALUE, so a schema refusing every
# collection cannot pass it; the planted arm adds one unknown field and must be refused by name.
row_collection_declaring_a_field_outside_its_closed_set='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  read = coll: builtins.toJSON (genMerge.evalModuleTree { } [
    { options.schema = genSchema.mkSchemaOption { collections.classes = coll; }; }
    { config.schema.user.classes = [ "darwin" ]; }
  ]).config.schema.user.classes;
  known = { default = [ ]; };
  typo = known // { typo = 1; };
in BODY'
check "T5 collection-declaring-a-field-outside-its-closed-set unplanted (a collection declaring only known fields resolves)" \
  "${row_collection_declaring_a_field_outside_its_closed_set/BODY/read known}" 0 "" "$tmpdir/collection-declaring-a-field-outside-its-closed-set-green.err" '["darwin"]'
check "T5 collection-declaring-a-field-outside-its-closed-set planted   (the same collection with an unknown field is refused by name)" \
  "${row_collection_declaring_a_field_outside_its_closed_set/BODY/read typo}" 1 \
  "gen-schema.mkSchemaOption: collection 'classes': 'typo' is not an option of this door; the options are closed" \
  "$tmpdir/collection-declaring-a-field-outside-its-closed-set-red.err"
check "T5 collection-declaring-a-field-outside-its-closed-set catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_collection_declaring_a_field_outside_its_closed_set/BODY/if (builtins.tryEval (builtins.deepSeq (read typo) null)).success then \"ADMITTED\" else \"CAUGHT\"}" \
  0 "" "$tmpdir/collection-declaring-a-field-outside-its-closed-set-catch.err" 'CAUGHT'
