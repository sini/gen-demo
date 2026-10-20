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
row_keysemantics_key_naming_a_structural_option_of_the_aspect_type='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  cnf = import ./aspect-cnf.nix;
  schemaWith = k: genAspects.mkAspectSchema (cnf // { keySemantics = cnf.keySemantics // { ${k}.category = "channel"; }; });
  gore = (merge.evalModuleTree { } [
      { options.aspects = (schemaWith "piping").mkAspectOption { }; }
      { aspects.gore = { welt = "selvedge"; }; }
    ]).config.aspects.gore;
  green = builtins.toJSON { inherit (gore) key welt; };
  planted = builtins.seq (schemaWith "meta") "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
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
