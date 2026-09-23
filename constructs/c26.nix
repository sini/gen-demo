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
{ genMerge, inputs }:
let
  c26Schema = inputs.gen.lib.substrate.schema;
  c26NotchDart =
    withInherit:
    c26Schema.evalSchema {
      schemaOption = c26Schema.mkSchemaOption { };
      modules = [
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
    };
  c26Instance =
    schema:
    (genMerge.evalModuleTree {
      modules = [
        { options.darts = c26Schema.mkInstanceRegistry schema.dart { }; }
        { config.darts.chambray.bevel = "shallow"; }
      ];
    }).config.darts.chambray;
  c26MirroredGrade = (c26Instance (c26NotchDart true)).grade;
  c26NoInheritHasGrade = (c26Instance (c26NotchDart false)) ? grade;
in
{
  inherit
    c26Schema
    c26NotchDart
    c26Instance
    c26MirroredGrade
    c26NoInheritHasGrade
    ;
}
