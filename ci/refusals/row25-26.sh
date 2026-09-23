# shellcheck shell=bash
# ── rows 25/26 -- `attrs` as a nullary container strategy, the two arms that must read the MESSAGE
# (den-hoag-241d7's spec rows 5 and 10; den-hoag-row12-message-cells-wrong-plane-x2stm).
#
# THEY LIVE HERE AND NOT IN `constructChecks`, AND THAT IS THE WHOLE POINT. Both inputs below THREW
# before the container strategy landed, so a cell asserting only the `tryEval` failure bit passes on
# the UNREPAIRED tree -- an oracle that cannot fail for the thing it was written to catch. What
# changed is the MESSAGE, which `tryEval` cannot read (header, above), so the discrimination is only
# available on this plane. Each row's `want_grep` is therefore the POST-component string: at
# gen-merge `08fcdd1e` row 25 refuses with "the option `selvedge' has conflicting definitions" and
# row 26 with "a definition for option `selvedge' is not of the expected type", and neither contains
# the substring its row requires.
#
# The construction mirrors C23's own `selvedge` declaration rather than importing it, as every row
# here does; `_file` is set because naming the offending FILE is half of what each message owes.
row25='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  decl = { options.selvedge = genMerge.mkOption { type = genMerge.types.attrs; }; };
in builtins.toJSON (genMerge.evalModuleTree {
  modules = [
    decl
    { _file = "/corpus/a.nix"; config.selvedge.warp = "flax"; }
    { _file = "/corpus/b.nix"; config.selvedge.SECONDKEY = "tussah"; }
  ];
}).config.selvedge'

check "T5 row25 unplanted (two files, disjoint keys -- the fold unions them)" "${row25/SECONDKEY/weft}" 0 "" \
  "$tmpdir/row25-green.err" '{"warp":"flax","weft":"tussah"}'
check "T5 row25 planted   (two files, the SAME key -- refused naming the key and both files)" \
  "${row25/SECONDKEY/warp}" 1 \
  "has \`attrs' definitions that collide at \`warp' (/corpus/b.nix, /corpus/a.nix)" \
  "$tmpdir/row25-red.err"

# Row 26's third and fourth arms are a CONTROL and its `catchable` twin, not unplanted counterparts,
# so they are labelled with distinct words and stay outside the pairing population the way row24's
# `catchable` does. `attrsOf int` over the SAME rejected definition used to abort uncatchably, which
# is what this control once pinned as the partition keeping `attrs` apart. gen-merge 5npwi fixed that
# abort: `attrs` and `attrsOf` now both check their domain through one `refusingOutside` binding, so
# the control pins that they AGREE -- `attrsOf` refuses the same definition by name, naming the file,
# and `tryEval` catches it (row 26, re-pointed by 5npwi).
row26Base='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  decl = { options.selvedge = genMerge.mkOption { type = TYPE; }; };
in builtins.toJSON (genMerge.evalModuleTree {
  modules = [
    decl
    { _file = "/corpus/bad.nix"; config.selvedge = DEFN; }
  ];
}).config.selvedge'
row26attrsetDefn='{ warp = "flax"; }'
row26attrs="${row26Base//TYPE/genMerge.types.attrs}"
row26="${row26attrs/DEFN/$row26attrsetDefn}"
row26planted="${row26attrs/DEFN/\"not-an-attrset\"}"
row26control="${row26Base//TYPE/(genMerge.types.attrsOf genMerge.types.int)}"
row26control="${row26control/DEFN/\"not-an-attrset\"}"

check "T5 row26 unplanted (an attrset definition the fold consumes)" "$row26" 0 "" \
  "$tmpdir/row26-green.err" '{"warp":"flax"}'
check "T5 row26 planted   (a string definition attrs cannot consume -- refused naming the file)" \
  "$row26planted" 1 \
  "has definitions \`attrs' cannot consume (/corpus/bad.nix)" \
  "$tmpdir/row26-red.err"
check "T5 row26 control   (attrsOf int over the SAME definition refuses by name, naming the file)" \
  "$row26control" 1 \
  "has definitions \`attrsOf' cannot consume (/corpus/bad.nix)" \
  "$tmpdir/row26-control.err"
check "T5 row26 catchable  (attrsOf's refusal is caught by tryEval, not an abort)" \
  "let v = ($row26control); in if (builtins.tryEval v).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/row26-catch.err" 'CAUGHT'
