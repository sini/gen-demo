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
row162='let
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
check "T5 row162 unplanted (a module under its own _file leaves the declared parent composed)" \
  "${row162/BODY/green}" 0 "" "$tmpdir/row162-green.err" 'waxed'
check "T5 row162 planted   (a def under the resolver's _file for the parent still composes it, not skipped)" \
  "${row162/BODY/planted}" 0 "" "$tmpdir/row162-red.err" 'waxed'
check "T5 row162 catchable  (the planted tree evaluates: the forged label is inert, not refused)" \
  "${row162/BODY/admitted}" 0 "" "$tmpdir/row162-catch.err" 'ADMITTED'
