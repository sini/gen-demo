# ── C26 — THE CORPUS'S OWN `inherits` PAIR RESOLVES A VALUE NEITHER SIDE DECLARES TWICE ──
# (den-hoag-0pk67, §2.7c step 5; ADR-0016 ruling 7, ADR-0033). `gen-modules/corpus.nix` now
# carries a real inheriting pair, `dart inherits notch`, and this cell reads it off the
# corpus's own composed VALUES — `genValues` IS that corpus's `config`, not a fixture.
# `genValues.darts.chambray` sets only `bevel`; `grade` is declared on `notch` alone and
# still resolves on the instance, because the staged pass folds the parent's option in
# before any instance is evaluated.
#
# The equality alone would be an accident of two static defaults agreeing, so the
# DISCRIMINATOR is driven in the same cell: the same `notch`/`dart` option shapes, built
# beside the corpus rather than by perturbing it (same discipline as C21 and `refusals.sh`
# row 13), with `inherits` dropped. Without the edge `dart` never gains `grade` as an option
# at all, so the same accessor is UNCATCHABLE — `attribute 'grade' missing` — which is the
# sharper failure this cell must show.
#
# THE `mkType` BRANCH (den-hoag-fwoa8): the same pair through a schema option whose `mkType`
# result is a bare module functor publishing no collections. `evalSchema` reads `inherits` off
# the kind value, so the entry type writes it there on both branches; the pair composes the
# same `grade`, and the twin without `inherits` still lacks it.
{ genMerge, inputs }:
let
  c26Schema = inputs.gen.lib.substrate.schema;
  c26Modules = withInherit: [
    {
      config.schema.notch.options.grade = genMerge.mkOption {
        type = genMerge.types.str;
        default = "waxed";
      };
      config.schema.dart = {
        inherits = if withInherit then [ "notch" ] else [ ];
        options.bevel = genMerge.mkOption { type = genMerge.types.str; };
      };
    }
  ];
  c26NotchDart =
    withInherit:
    c26Schema.evalSchema { schemaOption = c26Schema.mkSchemaOption { }; } (c26Modules withInherit);
  c26BareMkTypeNotchDart =
    withInherit:
    c26Schema.evalSchema {
      schemaOption = c26Schema.mkSchemaOption {
        mkType =
          { defs, ... }:
          {
            __functor =
              _:
              { ... }:
              {
                imports = map (d: d.value) defs;
              };
          };
      };
    } (c26Modules withInherit);
  c26Instance =
    schema:
    (genMerge.evalModuleTree { } [
      { options.darts = c26Schema.mkInstanceRegistry { } schema.dart; }
      { config.darts.chambray.bevel = "shallow"; }
    ]).config.darts.chambray;
  c26MirroredGrade = (c26Instance (c26NotchDart true)).grade;
  c26NoInheritHasGrade = (c26Instance (c26NotchDart false)) ? grade;
  # `or null`: an absent `grade` or `inherits` (the silent drop) reads as a value the cell asserts
  # against, so the cell reads false rather than aborting on the missing attribute.
  c26BareMkTypeGrade = (c26Instance (c26BareMkTypeNotchDart true)).grade or null;
  c26BareMkTypeInherits = (c26BareMkTypeNotchDart true).dart.inherits or null;
  c26BareMkTypeNoInheritHasGrade = (c26Instance (c26BareMkTypeNotchDart false)) ? grade;
  # THE CALLER'S `defs` SHAPE (den-hoag-4d2zs): one caller `mkType` publishing the per-def import
  # count of its `defs`, read off `dart` staged through `evalSchema` and on a plain tree. The twin
  # without `inherits` gets no nested def, so its shape is the discriminator.
  c26ShapeOption = c26Schema.mkSchemaOption {
    mkType =
      { defs, ... }:
      {
        __functor =
          _:
          { ... }:
          {
            imports = map (d: d.value) defs;
          };
        shape = map (d: builtins.length (d.value.imports or [ ])) defs;
      };
  };
  c26DefsShapeStaged =
    (c26Schema.evalSchema { schemaOption = c26ShapeOption; } (c26Modules true)).dart.shape;
  c26DefsShapeBare =
    (genMerge.evalModuleTree { } ([ { options.schema = c26ShapeOption; } ] ++ c26Modules true))
    .config.schema.dart.shape;
  c26DefsShapeNoInherit =
    (c26Schema.evalSchema { schemaOption = c26ShapeOption; } (c26Modules false)).dart.shape;
in
{
  inherit
    c26Schema
    c26Modules
    c26NotchDart
    c26BareMkTypeNotchDart
    c26Instance
    c26MirroredGrade
    c26NoInheritHasGrade
    c26BareMkTypeGrade
    c26BareMkTypeInherits
    c26BareMkTypeNoInheritHasGrade
    c26DefsShapeStaged
    c26DefsShapeBare
    c26DefsShapeNoInherit
    ;
}
