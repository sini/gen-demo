# shellcheck shell=bash
# ── row 28 -- a kind-declaration key NO reader consumes (gen-schema nn4) ──
# The class the arc names most often: something vanishes and nothing says so. A key on a STRUCTURED
# kind declaration that no reader consumes was discarded unread, and the discard was invisible to
# every instrument gen-schema owns -- a typo'd `spoool` produced a kind byte-identical to one
# declared without it. Owner-ruled 2026-08-19: mkSchemaOption aborts on an unknown kind key, by name.
# ★ THE PLANT IS A TYPO, not a foreign key, which is the whole point of the refusal: the two arms
# differ by one character and answered indistinguishably before the guard existed.
# ★ `options` is what makes the declaration STRUCTURED, and that is what puts it in the guard's
# domain. An unstructured declaration is config shorthand -- gen-merge reads every key of it -- and
# is not refused. The unplanted arm asserts a STDOUT VALUE, so a library that refused everything
# cannot pass it; the planted arm's exit code is what a library refusing nothing cannot pass.
row28='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  strOpt = genMerge.mkOption { type = genMerge.types.str; default = "linen"; };
in builtins.toJSON (builtins.attrNames (genMerge.evalModuleTree {
  modules = [
    { options.schema = genSchema.mkSchemaOption {}; }
    { config.schema.thimble = { options.spool = strOpt; SECONDSPOOL; }; }
  ];
}).config.schema.thimble.options)'
check "T5 row28 unplanted (the second spool DECLARED, the way gen-schema reads it)" \
  "${row28/SECONDSPOOL/options.spoool = strOpt}" 0 "" \
  "$tmpdir/row28-green.err" '["spool","spoool"]'
check "T5 row28 planted   (a typo on a structured kind declaration, read by nothing)" \
  "${row28/SECONDSPOOL/spoool = \"linen\"}" 1 \
  "gen-schema: kind 'thimble': unrecognised declaration key 'spoool'" \
  "$tmpdir/row28-red.err"
