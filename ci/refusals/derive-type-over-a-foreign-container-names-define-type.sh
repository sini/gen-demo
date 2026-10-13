# shellcheck shell=bash
# ── `deriveType` over a foreign container is refused by name, naming `defineType` (mirrors `foreign-knot-crossed-once`) ──
# A nixpkgs container carries its element under its author's own relation and states no `recarry`, so a
# derivation over it has no join that keeps every declared check, and gen-merge refuses it by name,
# pointing at the door that serves the same base. The unplanted arm is that door, `defineType` over the
# same base, given a value it admits, so a library refusing every foreign container cannot pass; the
# catchable arm holds that the refusal is a throw.
row_derive_type_over_a_foreign_container='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  base = lib.types.listOf lib.types.str;
  read = type: (genMerge.evalModuleTree { } [

      { options.weave = genMerge.mkOption { inherit type; }; }

      { weave = [ "sateen" ]; }

    ]).config.weave;
  green = builtins.head (read (genMerge.types.defineType base));
  planted = builtins.deepSeq (read (genMerge.deriveType { } "tagged" base)) "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 derive-type-over-a-foreign-container-names-define-type unplanted (defineType over the same base serves it)" \
  "${row_derive_type_over_a_foreign_container/BODY/green}" 0 "" "$tmpdir/derive-type-over-a-foreign-container-green.err" 'sateen'
check "T5 derive-type-over-a-foreign-container-names-define-type planted   (deriveType over it is refused by name, naming defineType)" \
  "${row_derive_type_over_a_foreign_container/BODY/planted}" 1 \
  "this library has no join of two such bases that keeps every check a declaration states. \`defineType' serves the base as itself" \
  "$tmpdir/derive-type-over-a-foreign-container-red.err"
check "T5 derive-type-over-a-foreign-container-names-define-type catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_derive_type_over_a_foreign_container/BODY/caught}" 0 "" "$tmpdir/derive-type-over-a-foreign-container-catch.err" 'CAUGHT'
