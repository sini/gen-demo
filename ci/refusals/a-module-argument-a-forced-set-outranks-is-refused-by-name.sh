# shellcheck shell=bash
# ── a module argument a whole forced `_module.args` set outranks is refused by name (den-hoag-b44rx) ──
# nixpkgs' option `_module.args` runs its override pass over each module's whole definition, the engine's
# own among them, so `_module.args = mkForce { … }` outranks a nested evaluation's position `name`, which
# is then undefined. The unplanted arm states no force, and `name` is the position's; the planted arm
# forces the whole set, and a module reading `name` is refused naming the argument, where nixpkgs aborts
# on `attribute 'name' missing`; the catchable arm holds that the refusal is a throw.
row_a_module_argument_a_forced_set_outranks='let
  flake = builtins.getFlake (toString ./.);
  gm = flake.inputs.gen.lib.modules.merge;
  read = args: (gm.evalModuleTree { } [
      {
        options.bolt = gm.mkOption {
          type = gm.types.submodule ({ name, ... }: { config._module.args = args; options.n = gm.mkOption { default = name; }; });
          default = { };
        };
      }
    ]).config.bolt.n;
  green = read { shuttle = 1; };
  planted = read (gm.mkForce { shuttle = 1; });
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-module-argument-a-forced-set-outranks-is-refused-by-name unplanted (no force: the position name is served)" \
  "${row_a_module_argument_a_forced_set_outranks/BODY/green}" 0 "" "$tmpdir/a-module-argument-a-forced-set-outranks-green.err" 'bolt'
check "T5 a-module-argument-a-forced-set-outranks-is-refused-by-name planted   (a forced set outranks the position name: refused by name)" \
  "${row_a_module_argument_a_forced_set_outranks/BODY/planted}" 1 \
  "gen-merge: module argument \`name' is not defined" \
  "$tmpdir/a-module-argument-a-forced-set-outranks-red.err"
check "T5 a-module-argument-a-forced-set-outranks-is-refused-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_module_argument_a_forced_set_outranks/BODY/caught}" 0 "" "$tmpdir/a-module-argument-a-forced-set-outranks-catch.err" 'CAUGHT'
