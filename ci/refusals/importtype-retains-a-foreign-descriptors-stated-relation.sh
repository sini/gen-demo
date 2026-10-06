# shellcheck shell=bash
# ── row 152 -- importType retains a foreign descriptor's stated relation, and refuses one its functor
#    cannot answer for, BY NAME (gen-merge 0c11b23c, candidate D; ADR-0025 item 1) ──
# Row 18 declares the landing's `exportType` limb (the republished functor). This is the `importType`
# limb: a foreign descriptor stating `functor.binOp` has that relation retained and applied unread,
# where it used to be discarded and the type merged on its NAME ALONE. The retention is applied through
# the protocol's own default, which reads `name` and `type` off the functor, so a functor stating `binOp`
# and omitting `type` is refused at the door (`relationGaps`) instead of dying at a merge site the author
# never wrote. The unplanted arm is the complete functor: it imports, merges with a partner its own
# `binOp` accepts, and DECLINES one it does not (the retention, not a name-only merge).
row_importtype_retains_a_foreign_descriptors_stated_relation='let
  genMerge = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules.merge;
  box = elem: genMerge.mkOptionType {
    name = "boxType";
    functor = {
      name = "boxType";
      payload.elemType = elem;
      binOp = a: b: if a.elemType.name == b.elemType.name then a else null;
      TYPEFIELD
    };
    getSubOptions = _p: { };
    getSubModules = null;
    substSubModules = _m: null;
  };
  same = ((box genMerge.types.str).typeMerge (box genMerge.types.str).functor).name;
  differing = (box genMerge.types.str).typeMerge (box genMerge.types.int).functor;
in BODY'
row_importtype_retains_a_foreign_descriptors_stated_relationok="${row_importtype_retains_a_foreign_descriptors_stated_relation/TYPEFIELD/type = pl: box pl.elemType;}"
row_importtype_retains_a_foreign_descriptors_stated_relationgap="${row_importtype_retains_a_foreign_descriptors_stated_relation/TYPEFIELD/}"
row_importtype_retains_a_foreign_descriptors_stated_relationread='same + ":" + (if differing == null then "DECLINED" else "MERGED")'
check "T5 importtype-retains-a-foreign-descriptors-stated-relation unplanted (a complete stated relation imports; its own binOp decides the merge)" \
  "${row_importtype_retains_a_foreign_descriptors_stated_relationok/BODY/$row_importtype_retains_a_foreign_descriptors_stated_relationread}" 0 "" "$tmpdir/importtype-retains-a-foreign-descriptors-stated-relation-green.err" 'boxType:DECLINED'
check "T5 importtype-retains-a-foreign-descriptors-stated-relation planted   (a stated relation whose functor omits \`type' is refused by name)" \
  "${row_importtype_retains_a_foreign_descriptors_stated_relationgap/BODY/$row_importtype_retains_a_foreign_descriptors_stated_relationread}" 1 \
  "gen-merge: the option type \`boxType' states a merge relation in \`functor.binOp' but its \`functor' does not answer \`type'" \
  "$tmpdir/importtype-retains-a-foreign-descriptors-stated-relation-red.err"
check "T5 importtype-retains-a-foreign-descriptors-stated-relation catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_importtype_retains_a_foreign_descriptors_stated_relationgap/BODY/if (builtins.tryEval (builtins.deepSeq same true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/importtype-retains-a-foreign-descriptors-stated-relation-catch.err" 'CAUGHT'
