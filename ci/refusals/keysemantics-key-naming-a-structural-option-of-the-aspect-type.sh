# shellcheck shell=bash
# ── keysemantics-key-naming-a-structural-option-of-the-aspect-type -- a keySemantics key spelled as
#    one of the aspect type's six structural options, BY NAME at the cnf door (gen-aspects, den-hoag-erq8j) ──
# Each keySemantics key becomes an option of the aspect type beside `name`, `description`, `key`,
# `id_hash`, `meta` and `includes`, and one spelled as a structural option REPLACED it while
# `keyCategory` still answered "structural". ★ WHAT THE PLANTED ARM DID BEFORE THE DOOR, measured in
# this corpus at gen-aspects b7760e8: forcing the schema exited 0 (`SERVED`), and every aspect's `key`
# then threw `identity: \`gore\` sets meta.aspect-chain = a set, which contradicts its declared path`,
# blaming a write nobody made. ★ THE UNPLANTED ARM declares the same channel under an ordinary name
# and reads the corpus channel `welt` beside the aspect's identity key, so a door that refused every
# added key cannot pass it.
# ★ THE ENGINE ARMS (gen-aspects, den-hoag-jbddy): the same door refuses a keySemantics key naming a
# key the module engine owns in every aspect's option tree, `_module` and `_freeformOptions`, read off
# gen-merge at the aspect's own freeform shape. Measured in this corpus before that door, at the hub's
# gen-aspects b7760e8: both forced the schema to exit 0 (`SERVED`); a channel `_module` then made every
# aspect read throw gen-merge's per-read refusal, and a channel `_freeformOptions` silently replaced the
# declared option. ★ THEIR UNPLANTED ARM declares the channel as `records`, an ordinary name.
row_keysemantics_key_naming_a_structural_option_of_the_aspect_type='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  cnf = import ./aspect-cnf.nix;
  schemaWith = k: genAspects.mkAspectSchema (cnf // { keySemantics = cnf.keySemantics // { ${k}.category = "channel"; }; });
  goreWith = k: (merge.evalModuleTree { } [
      { options.aspects = (schemaWith k).mkAspectOption { }; }
      { aspects.gore = { welt = "selvedge"; }; }
    ]).config.aspects.gore;
  green = builtins.toJSON { inherit (goreWith "piping") key welt; };
  greenRecords = builtins.toJSON { inherit (goreWith "records") key welt; };
  plantedWith = k: builtins.seq (schemaWith k) "SERVED";
  caughtWith = k: if (builtins.tryEval (plantedWith k)).success then "ADMITTED" else "CAUGHT";
  planted = plantedWith "meta";
  caught = caughtWith "meta";
  plantedModule = plantedWith "_module";
  caughtModule = caughtWith "_module";
  plantedFreeform = plantedWith "_freeformOptions";
  caughtFreeform = caughtWith "_freeformOptions";
in BODY'
check "T5 keysemantics-key-naming-a-structural-option-of-the-aspect-type unplanted (a channel under an ordinary name keeps the aspect identity and the corpus channel)" \
  "${row_keysemantics_key_naming_a_structural_option_of_the_aspect_type/BODY/green}" 0 "" \
  "$tmpdir/keysemantics-key-naming-a-structural-option-of-the-aspect-type-green.err" '{"key":"gore","welt":"selvedge"}'
check "T5 keysemantics-key-naming-a-structural-option-of-the-aspect-type planted   (a channel named meta is refused by name at the cnf door)" \
  "${row_keysemantics_key_naming_a_structural_option_of_the_aspect_type/BODY/planted}" 1 \
  "gen-aspects: keySemantics key 'meta' names a structural option of the aspect type (name, description, key, id_hash, meta, includes); a keySemantics entry declares a key beside them, never over one." \
  "$tmpdir/keysemantics-key-naming-a-structural-option-of-the-aspect-type-red.err"
check "T5 keysemantics-key-naming-a-structural-option-of-the-aspect-type catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_keysemantics_key_naming_a_structural_option_of_the_aspect_type/BODY/caught}" 0 "" \
  "$tmpdir/keysemantics-key-naming-a-structural-option-of-the-aspect-type-catch.err" 'CAUGHT'
check "T5 keysemantics-key-naming-a-structural-option-of-the-aspect-type unplanted (a channel named records keeps the aspect identity and the corpus channel)" \
  "${row_keysemantics_key_naming_a_structural_option_of_the_aspect_type/BODY/greenRecords}" 0 "" \
  "$tmpdir/keysemantics-key-naming-a-structural-option-of-the-aspect-type-green-records.err" '{"key":"gore","welt":"selvedge"}'
check "T5 keysemantics-key-naming-a-structural-option-of-the-aspect-type planted   (a channel named _module is refused by name at the cnf door)" \
  "${row_keysemantics_key_naming_a_structural_option_of_the_aspect_type/BODY/plantedModule}" 1 \
  "gen-aspects: keySemantics key '_module' names a key the module engine owns in every aspect's option tree (_freeformOptions, _module); a keySemantics entry declares a key beside them, never over one." \
  "$tmpdir/keysemantics-key-naming-a-structural-option-of-the-aspect-type-red-module.err"
check "T5 keysemantics-key-naming-a-structural-option-of-the-aspect-type catchable  (the _module refusal is caught by tryEval, not an abort)" \
  "${row_keysemantics_key_naming_a_structural_option_of_the_aspect_type/BODY/caughtModule}" 0 "" \
  "$tmpdir/keysemantics-key-naming-a-structural-option-of-the-aspect-type-catch-module.err" 'CAUGHT'
check "T5 keysemantics-key-naming-a-structural-option-of-the-aspect-type planted   (a channel named _freeformOptions is refused by name at the cnf door)" \
  "${row_keysemantics_key_naming_a_structural_option_of_the_aspect_type/BODY/plantedFreeform}" 1 \
  "gen-aspects: keySemantics key '_freeformOptions' names a key the module engine owns in every aspect's option tree (_freeformOptions, _module); a keySemantics entry declares a key beside them, never over one." \
  "$tmpdir/keysemantics-key-naming-a-structural-option-of-the-aspect-type-red-freeform.err"
check "T5 keysemantics-key-naming-a-structural-option-of-the-aspect-type catchable  (the _freeformOptions refusal is caught by tryEval, not an abort)" \
  "${row_keysemantics_key_naming_a_structural_option_of_the_aspect_type/BODY/caughtFreeform}" 0 "" \
  "$tmpdir/keysemantics-key-naming-a-structural-option-of-the-aspect-type-catch-freeform.err" 'CAUGHT'
