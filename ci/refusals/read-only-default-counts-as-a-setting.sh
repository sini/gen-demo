# shellcheck shell=bash
# ── a read-only option's declared default counts as a setting, as nixpkgs' `defs'` counts it
# (den-hoag-1gv6r): planted, one definition beside the default; unplanted, the default alone ──
row_read_only_default_counts_as_a_setting='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  tree = genMerge.evalModuleTree { } ([
      { options.spool = genMerge.mkOption { type = genMerge.types.int; readOnly = true; default = 1; }; }
    ] ++ ARG);
in builtins.toJSON tree.config.spool'
check "T5 read-only-default-counts-as-a-setting unplanted (the declared default alone)" "${row_read_only_default_counts_as_a_setting/ARG/[ ]}" 0 "" \
  "$tmpdir/read-only-default-counts-as-a-setting-green.err" '1'
# A `}` in a `${var/pattern/replacement}` replacement closes the expansion, so the planted list is
# held in a variable.
planted_read_only_default_counts_as_a_setting='[ { spool = 2; } ]'
check "T5 read-only-default-counts-as-a-setting planted   (one definition beside the declared default)" "${row_read_only_default_counts_as_a_setting/ARG/$planted_read_only_default_counts_as_a_setting}" 1 \
  "is read-only, but it is defined 2 times (its declared default counts as one)" \
  "$tmpdir/read-only-default-counts-as-a-setting-red.err"
