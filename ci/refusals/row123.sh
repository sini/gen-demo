# shellcheck shell=bash
# ── row 123 -- a declared `inherits` on a tree `evalSchema` did not build composes as the import it
#    desugars to, and a parent nothing declares or an inheritance cycle is refused BY NAME, catchably,
#    at gen-schema's kind entry (den-hoag-8c8pr Q-a and Q-b arm (i); ADR-0025 item 1) ──
# C26's `notch`/`dart` pair from the other side. On a plain `mkSchemaOption` tree (den v1's shape) the
# declaration means what `imports = [ config.schema.notch ]` means there, so the unplanted arm asserts
# a STDOUT VALUE: `notch`'s `grade` reaches `dart`'s instance, and a door that refused everything
# cannot pass it. The planted arms leave `notch` undeclared, or have `notch` inherit `dart` back.
row123='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  notch = extra: { notch = { options.grade = merge.mkOption { type = merge.types.str; default = "waxed"; }; } // extra; };
  dart = {
    dart = {
      inherits = [ "notch" ];
      options.bevel = merge.mkOption { type = merge.types.str; };
    };
  };
  plainTree = kinds: (merge.evalModuleTree {
    modules = [ { options.schema = schema.mkSchemaOption { }; } { config.schema = kinds; } ];
  }).config.schema;
  gradeOf = kinds: (merge.evalModuleTree {
    modules = [
      { options.darts = schema.mkInstanceRegistry kinds.dart { }; }
      { config.darts.chambray.bevel = "shallow"; }
    ];
  }).config.darts.chambray.grade;
  green = gradeOf (plainTree (notch { } // dart));
  planted = gradeOf (plainTree dart);
  red = planted;
  cycle = gradeOf (plainTree (notch { inherits = [ "dart" ]; } // dart));
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row123 unplanted (the pair on a plain tree composes the parent, as the import it desugars to)" \
  "${row123/BODY/green}" 0 "" "$tmpdir/row123-green.err" 'waxed'
check "T5 row123 planted   (the same plain tree with the parent undeclared is refused by name)" \
  "${row123/BODY/red}" 1 \
  "gen-schema: kind 'dart' inherits 'notch' which is not a declared kind" \
  "$tmpdir/row123-red.err"
check "T5 row123 cycle     (the parent inheriting the child back is refused by name)" \
  "${row123/BODY/cycle}" 1 \
  "gen-schema: kind 'dart' reaches a kind with its own content witness through its parents (dart -> notch -> dart), among kinds [dart notch]: either it inherits itself, an inheritance cycle" \
  "$tmpdir/row123-cycle.err"
check "T5 row123 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row123/BODY/caught}" 0 "" "$tmpdir/row123-catch.err" 'CAUGHT'
