# shellcheck shell=bash
# ── a gen-typed declaration reading config at declaration time is refused by name (den-hoag-2tna3) ──
# ADR-0033's stratum refusal yields to a nixpkgs-grammar declaration in a module not declared gen
# grammar, which reads `config` while the declarations are folded as nixpkgs' fold lets it; a
# declaration whose own top type constructor is gen's keeps the refusal. The unplanted arm is the
# nixpkgs-typed declaration, served; the planted arm the same declaration with gen's `mkOption` and
# type, refused naming the read; the catchable arm holds that the refusal is a throw.
row_a_gen_declaration_reading_config='let
  flake = builtins.getFlake (toString ./.);
  lib = flake.inputs.nixpkgs.lib;
  gm = flake.inputs.gen.lib.modules.merge;
  read = mk: ty: (gm.evalModuleTree { specialArgs = { inherit lib; }; } [
      { options.selvage = lib.mkOption { type = lib.types.str; default = "tabby"; }; }
      ({ config, ... }: { options.bobbin = mk { type = ty; } // lib.optionalAttrs (config.selvage == "tabby") { default = "twill"; }; })
    ]).config.bobbin;
  green = read lib.mkOption lib.types.str;
  planted = read gm.mkOption gm.types.str;
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-gen-declaration-reading-config-is-refused-by-name unplanted (a nixpkgs-typed declaration reading config is served)" \
  "${row_a_gen_declaration_reading_config/BODY/green}" 0 "" "$tmpdir/a-gen-declaration-reading-config-green.err" 'twill'
check "T5 a-gen-declaration-reading-config-is-refused-by-name planted   (a gen-typed declaration reading config is refused by name)" \
  "${row_a_gen_declaration_reading_config/BODY/planted}" 1 \
  "gen-merge: a module read \`config' while its own declarations were being folded" \
  "$tmpdir/a-gen-declaration-reading-config-red.err"
check "T5 a-gen-declaration-reading-config-is-refused-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_gen_declaration_reading_config/BODY/caught}" 0 "" "$tmpdir/a-gen-declaration-reading-config-catch.err" 'CAUGHT'
