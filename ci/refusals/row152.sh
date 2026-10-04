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
row152='let
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
row152ok="${row152/TYPEFIELD/type = pl: box pl.elemType;}"
row152gap="${row152/TYPEFIELD/}"
row152read='same + ":" + (if differing == null then "DECLINED" else "MERGED")'
check "T5 row152 unplanted (a complete stated relation imports; its own binOp decides the merge)" \
  "${row152ok/BODY/$row152read}" 0 "" "$tmpdir/row152-green.err" 'boxType:DECLINED'
check "T5 row152 planted   (a stated relation whose functor omits \`type' is refused by name)" \
  "${row152gap/BODY/$row152read}" 1 \
  "gen-merge: the option type \`boxType' states a merge relation in \`functor.binOp' but its \`functor' does not answer \`type'" \
  "$tmpdir/row152-red.err"
check "T5 row152 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row152gap/BODY/if (builtins.tryEval (builtins.deepSeq same true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row152-catch.err" 'CAUGHT'
