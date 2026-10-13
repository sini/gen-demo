# shellcheck shell=bash
# ── row 72 -- a foreign check-family type redeclared keeps its check (gen-merge den-hoag-0lq9s) ──
# nixpkgs' `addCheck` keeps its base's functor, so a `port` redeclared as `int` joins to bare `int`
# and nixpkgs accepts 70000 for a port. gen-merge meets that join with every operand (den-hoag-rmxbx,
# G11), so `port`'s check still refuses 70000 and 8080 is served; a `port` redeclared from one shared
# value keeps its own check. The unplanted arms print the value, so a library refusing every
# redeclaration cannot pass them; the planted arms exit 1, so a library dropping the check cannot.
row_foreign_check_family_type_redeclared_keeps_its_check='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
in toString (genMerge.evalModuleTree { } [
    { options.lathe.spindle = genMerge.mkOption { type = lib.types.port; }; }
    { options.lathe.spindle = genMerge.mkOption { type = SECOND; }; }
    { _file = "/demo/lathe.nix"; lathe.spindle = VALUE; }
  ]).config.lathe.spindle'
row_foreign_check_family_type_redeclared_keeps_its_checka="${row_foreign_check_family_type_redeclared_keeps_its_check/SECOND/lib.types.port}"
row_foreign_check_family_type_redeclared_keeps_its_checkb="${row_foreign_check_family_type_redeclared_keeps_its_check/SECOND/lib.types.int}"
check "T5 foreign-check-family-type-redeclared-keeps-its-check unplanted (port redeclared as the same port, 8080)" "${row_foreign_check_family_type_redeclared_keeps_its_checka/VALUE/8080}" 0 "" \
  "$tmpdir/foreign-check-family-type-redeclared-keeps-its-check-green.err" '8080'
check "T5 foreign-check-family-type-redeclared-keeps-its-check unplanted (port redeclared as int, 8080: the met join serves it)" "${row_foreign_check_family_type_redeclared_keeps_its_checkb/VALUE/8080}" 0 "" \
  "$tmpdir/foreign-check-family-type-redeclared-keeps-its-check-green-int.err" '8080'
check "T5 foreign-check-family-type-redeclared-keeps-its-check planted   (port redeclared as int, 70000: the join to int is met with the port check)" \
  "${row_foreign_check_family_type_redeclared_keeps_its_checkb/VALUE/70000}" 1 \
  "gen-merge: a definition for option \`lathe.spindle' is not of type" \
  "$tmpdir/foreign-check-family-type-redeclared-keeps-its-check-red.err"
check "T5 foreign-check-family-type-redeclared-keeps-its-check planted   (port twin, 70000: the shared twin keeps its check)" \
  "${row_foreign_check_family_type_redeclared_keeps_its_checka/VALUE/70000}" 1 \
  "gen-merge: a definition for option \`lathe.spindle' is not of type \`16 bit unsigned integer; between 0 and 65535 (both inclusive)', in \`/demo/lathe.nix'" \
  "$tmpdir/foreign-check-family-type-redeclared-keeps-its-check-twin.err"
