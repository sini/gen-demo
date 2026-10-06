# shellcheck shell=bash
# ── row 162 -- a def that carries the resolver's `_file` for a declared parent does not make the plain-tree
#    desugar skip that parent: the label is a claim, the value is what counts (den-hoag-5n8ey; ADR-0025 item 1) ──
# Row 123's `notch`/`dart` pair on a plain `mkSchemaOption` tree. A user module may set `_file` to the
# string `evalSchema`'s pass writes for `dart` inheriting `notch`; gen-schema counts that string as the
# resolver's only on a def whose value is exactly one import, so a def with that string and its own
# option is an ordinary def and `notch` still composes. This is a CONSTRUCTION, not a refusal: the
# planted arm is a VALUE assertion (`grade` is read through `dart`'s instance, `waxed`), so a door that
# dropped `notch` fails it, and nothing is refused. The unplanted arm is a module under its own `_file`.
# The catchable arm's token is `ADMITTED`, not row 123's `CAUGHT`: the planted tree must evaluate.
row_def_that_carries_the_resolvers_file_for_a_declared_parent_does_not_make_the_plain_tree='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  notch = { notch = { options.grade = merge.mkOption { type = merge.types.str; default = "waxed"; }; }; };
  dart = {
    dart = {
      inherits = [ "notch" ];
      options.bevel = merge.mkOption { type = merge.types.str; };
    };
  };
  own = file: {
    _file = file;
    config.schema.dart.options.own = merge.mkOption { type = merge.types.str; default = "o"; };
  };
  plainTree = mods: (merge.evalModuleTree { } ([ { options.schema = schema.mkSchemaOption { }; } { config.schema = notch // dart; } ] ++ mods)).config.schema;
  gradeOf = kinds: (merge.evalModuleTree { } [
      { options.darts = schema.mkInstanceRegistry { } kinds.dart; }
      { config.darts.chambray.bevel = "shallow"; }
    ]).config.darts.chambray.grade;
  green = gradeOf (plainTree [ (own "<my own module>") ]);
  planted = gradeOf (plainTree [ (own "<gen-schema evalSchema: kind '"'"'dart'"'"' inherits '"'"'notch'"'"'>") ]);
  admitted = if (builtins.tryEval planted).success then "ADMITTED" else "REFUSED";
in BODY'
check "T5 def-that-carries-the-resolvers-file-for-a-declared-parent-does-not-make-the-plain-tree unplanted (a module under its own _file leaves the declared parent composed)" \
  "${row_def_that_carries_the_resolvers_file_for_a_declared_parent_does_not_make_the_plain_tree/BODY/green}" 0 "" "$tmpdir/def-that-carries-the-resolvers-file-for-a-declared-parent-does-not-make-the-plain-tree-green.err" 'waxed'
check "T5 def-that-carries-the-resolvers-file-for-a-declared-parent-does-not-make-the-plain-tree planted   (a def under the resolver's _file for the parent still composes it, not skipped)" \
  "${row_def_that_carries_the_resolvers_file_for_a_declared_parent_does_not_make_the_plain_tree/BODY/planted}" 0 "" "$tmpdir/def-that-carries-the-resolvers-file-for-a-declared-parent-does-not-make-the-plain-tree-red.err" 'waxed'
check "T5 def-that-carries-the-resolvers-file-for-a-declared-parent-does-not-make-the-plain-tree catchable  (the planted tree evaluates: the forged label is inert, not refused)" \
  "${row_def_that_carries_the_resolvers_file_for_a_declared_parent_does_not_make_the_plain_tree/BODY/admitted}" 0 "" "$tmpdir/def-that-carries-the-resolvers-file-for-a-declared-parent-does-not-make-the-plain-tree-catch.err" 'ADMITTED'
