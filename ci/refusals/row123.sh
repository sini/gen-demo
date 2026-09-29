# shellcheck shell=bash
# ── row 123 -- a declared `inherits` on a tree `evalSchema` did not build is refused BY NAME, catchably,
#    at gen-schema's kind entry (den-hoag-8c8pr; ADR-0025 item 1) ──
# C26's `notch`/`dart` pair from the other side. `evalSchema` is the only resolver of `inherits`; on a
# plain `mkSchemaOption` tree the parent's `grade` was silently absent, and the accessor aborted as
# `attribute 'grade' missing`. The arms differ only in how the tree is built: the unplanted arm stages
# the same modules through `evalSchema` and asserts a STDOUT VALUE, so a door that refused everything
# cannot pass it.
row123='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  mods = [
    {
      config.schema.notch.options.grade = merge.mkOption { type = merge.types.str; default = "waxed"; };
      config.schema.dart = {
        inherits = [ "notch" ];
        options.bevel = merge.mkOption { type = merge.types.str; };
      };
    }
  ];
  plainTree = (merge.evalModuleTree {
    modules = [ { options.schema = schema.mkSchemaOption { }; } ] ++ mods;
  }).config.schema;
  gradeOf = kinds: (merge.evalModuleTree {
    modules = [
      { options.darts = schema.mkInstanceRegistry kinds.dart { }; }
      { config.darts.chambray.bevel = "shallow"; }
    ];
  }).config.darts.chambray.grade;
  green = gradeOf (schema.evalSchema { modules = mods; });
  planted = gradeOf plainTree;
  red = planted;
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row123 unplanted (the pair staged through evalSchema composes the parent)" \
  "${row123/BODY/green}" 0 "" "$tmpdir/row123-green.err" 'waxed'
check "T5 row123 planted   (the same pair on a plain tree is refused as unresolved)" \
  "${row123/BODY/red}" 1 \
  "gen-schema: kind 'dart' inherits 'notch', but nothing resolved it" \
  "$tmpdir/row123-red.err"
check "T5 row123 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row123/BODY/caught}" 0 "" "$tmpdir/row123-catch.err" 'CAUGHT'
