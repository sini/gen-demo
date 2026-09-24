# shellcheck shell=bash
# ── row 72 -- a foreign check-family type redeclared keeps its check (gen-merge den-hoag-0lq9s) ──
# nixpkgs' `addCheck` keeps its base's functor, so a `port` redeclared as `int` joins to bare `int`
# and nixpkgs accepts 70000 for a port. gen-merge refuses a foreign join that drops a name an
# operand states, and a `port` redeclared from one shared value keeps its own check. The unplanted
# arm prints the value, so a library refusing every redeclaration cannot pass it; the planted arms
# exit 1, so a library refusing nothing cannot.
row72='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
in toString (genMerge.evalModuleTree {
  modules = [
    { options.lathe.spindle = genMerge.mkOption { type = lib.types.port; }; }
    { options.lathe.spindle = genMerge.mkOption { type = SECOND; }; }
    { _file = "/demo/lathe.nix"; lathe.spindle = VALUE; }
  ];
}).config.lathe.spindle'
row72a="${row72/SECOND/lib.types.port}"
row72b="${row72/SECOND/lib.types.int}"
check "T5 row72 unplanted (port redeclared as the same port, 8080)" "${row72a/VALUE/8080}" 0 "" \
  "$tmpdir/row72-green.err" '8080'
check "T5 row72 planted   (port redeclared as int: the join to int drops the port check)" \
  "${row72b/VALUE/8080}" 1 \
  "is declared with types that do not merge (\`int' and \`unsignedInt16', which their own relation joins to \`int', a type that states the check \`int' declares but not the check \`unsignedInt16' declares)" \
  "$tmpdir/row72-red.err"
check "T5 row72 planted   (port twin, 70000: the shared twin keeps its check)" \
  "${row72a/VALUE/70000}" 1 \
  "gen-merge: a definition for option \`lathe.spindle' is not of type \`16 bit unsigned integer; between 0 and 65535 (both inclusive)', in \`/demo/lathe.nix'" \
  "$tmpdir/row72-twin.err"
