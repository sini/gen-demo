# shellcheck shell=bash
# ── collection-named-for-a-key-the-aspect-kind-value-writes -- an `mkAspectSchema` collection named
#    `__defsModule`, the key gen-aspects writes onto the aspect kind value, BY NAME (den-hoag-erq8j) ──
# gen-aspects' `mkType` builds the kind value as `{ __functor; kind; } // collections // { __defsModule; }`,
# so a collection named `__defsModule` was REPLACED by the native module. ★ WHAT THE PLANTED ARM DID
# BEFORE THE REFUSAL, measured at gen-aspects b7760e8: it exited 0 (`SERVED`), and the collection's
# value was lost without a word. ★ THE UNPLANTED ARM declares the same collection as `tags` and reads
# its value back on the kind, so a door that refused every collection cannot pass it.
row_collection_named_for_a_key_the_aspect_kind_value_writes='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  kindWith = n: let schema = genAspects.mkAspectSchema ((import ./aspect-cnf.nix) // { collections.${n}.default = "selvedge"; }); in
    (merge.evalModuleTree { } [
      { options.schema = schema.schemaOption; }
      { config.schema.aspect = { }; }
    ]).config.schema.aspect;
  green = builtins.toJSON (kindWith "tags").tags;
  planted = builtins.deepSeq (builtins.attrNames (kindWith "__defsModule")) "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 collection-named-for-a-key-the-aspect-kind-value-writes unplanted (a collection under an ordinary name reads back its value on the kind)" \
  "${row_collection_named_for_a_key_the_aspect_kind_value_writes/BODY/green}" 0 "" \
  "$tmpdir/collection-named-for-a-key-the-aspect-kind-value-writes-green.err" '"selvedge"'
check "T5 collection-named-for-a-key-the-aspect-kind-value-writes planted   (a collection named __defsModule is refused by name)" \
  "${row_collection_named_for_a_key_the_aspect_kind_value_writes/BODY/planted}" 1 \
  "gen-aspects: mkAspectSchema: collection '__defsModule' is reserved — the aspect kind value writes it" \
  "$tmpdir/collection-named-for-a-key-the-aspect-kind-value-writes-red.err"
check "T5 collection-named-for-a-key-the-aspect-kind-value-writes catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_collection_named_for_a_key_the_aspect_kind_value_writes/BODY/caught}" 0 "" \
  "$tmpdir/collection-named-for-a-key-the-aspect-kind-value-writes-catch.err" 'CAUGHT'
