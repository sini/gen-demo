# shellcheck shell=bash
# ── a copy of a built submodule record, re-entered through gen's `mkOptionType` door with its
# `substSubModules` rewritten to a value that cannot be applied, is refused by name ──
# nixpkgs aborts on its own twin (`attempt to call something which is not a function`). The copy used
# to keep the base's rebuild unannounced on `5` and `{ }`, and abort on a functor returning `5`. The
# unplanted arm is the same copy with an applicable rewrite that adds `y = 7`, and prints it, so a
# door refusing every rewrite cannot pass; the catchable arm holds that the refusal is a throw.
row_a_copy_rewriting_its_rebuild_to_a_non_function_is_refused_by_name='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  t = genMerge.types;
  base = t.submodule { options.warp = genMerge.mkOption { type = t.int; default = 1; }; };
  copy = s: genMerge.mkOptionType (builtins.removeAttrs (base // { substSubModules = s; }) [
    "functor" "typeMerge" "__mint" "__okAt" "__payload" "__sealed" "__typeSelf"
  ]);
  read = s: (genMerge.evalModuleTree { } [
      { options.bolt = genMerge.mkOption { type = copy s; default = { }; }; }
      { bolt.warp = 2; }
    ]).config.bolt;
  weft = m: base.substSubModules (m ++ [ { options.weft = genMerge.mkOption { type = t.int; default = 7; }; } ]);
  green = toString (read weft).weft;
  planted = builtins.deepSeq (read 5) "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-copy-rewriting-its-rebuild-to-a-non-function-is-refused-by-name unplanted (an applicable rewrite is taken)" \
  "${row_a_copy_rewriting_its_rebuild_to_a_non_function_is_refused_by_name/BODY/green}" 0 "" \
  "$tmpdir/a-copy-rewriting-its-rebuild-to-a-non-function-is-refused-by-name-green.err" '7'
check "T5 a-copy-rewriting-its-rebuild-to-a-non-function-is-refused-by-name planted   (a rewrite to 5 is refused by name)" \
  "${row_a_copy_rewriting_its_rebuild_to_a_non_function_is_refused_by_name/BODY/planted}" 1 \
  "whose \`substSubModules' is rewritten to a value that cannot be applied" \
  "$tmpdir/a-copy-rewriting-its-rebuild-to-a-non-function-is-refused-by-name-red.err"
check "T5 a-copy-rewriting-its-rebuild-to-a-non-function-is-refused-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_copy_rewriting_its_rebuild_to_a_non_function_is_refused_by_name/BODY/caught}" 0 "" \
  "$tmpdir/a-copy-rewriting-its-rebuild-to-a-non-function-is-refused-by-name-catch.err" 'CAUGHT'
