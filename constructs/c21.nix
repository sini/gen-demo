# ── C21 — THE SCHEMA-INHERITANCE RELOCATION PRESERVES THE CORPUS KIND'S IDENTITY CONTENT ──
# (ADR-0016 ruling 7, ADR-0033). §2.6 of the relocation moved every kind declaration off the
# live `config.schema.<k>` crossing and onto gen-schema's staged `evalSchema` pass, where a
# parent travels as a NAME instead of being read out of the tree being declared.
#
# WHAT IS PRESERVED IS THE CONTENT, NOT THE STAMP. The retired and the relocated spelling are two
# DECLARATIONS — `kindEq` has called them distinct since before the stamp carried the kind — and an
# instance stamp carries its kind's minted identity (ADR-0034: nothing mints or keys by a name). So
# the stamps FOLLOW `kindEq`, and the relocation's invariant is that the relocated instance,
# recomputed under the retired kind, is the retired instance, over one closed key set. The
# proposition "the two spellings mint ONE `id_hash`" held only while the stamp's kind input was the
# name, and it is retired.
#
# THREE ARMS, ONE COMPOSITION ATTRIBUTE APART, over the corpus's real instrument: gen-aspects'
# own `schemaOption`, `mkInstanceRegistry`, and C17's `extraModules` inlet.
#   head       — the RETIRED idiom, `imports = [ config.schema.hank ]`. It is APPARATUS, not a
#                survival of the migrated class: the reference value has to be built the old
#                way or there is nothing for the new way to be compared against.
#   relocated  — `inherits = [ "hank" ]`, resolved by the staged pass.
#   no-inherit — the same staged tree with the parent dropped: the PERTURBATION.
#
# `hank` carries ONE primitive option, so it enters the identity key set (`name`/`selvage`/
# `spool` against `name`/`spool`): dropping the inheritance moves the KEY SET, which is where the
# perturbation is judged, since two declarations' stamps differ whatever their keys are. The
# no-inherit arm's content and key set are the corpus's own thimble's (`c17Thimble`/`c17Pewter`),
# which is what shows this instrument is the corpus's and not a lookalike built beside it.
#
# Exported as INSTANCES and KINDS, not only stamps, because every conjunct above is a relation over
# the kind, the key set and the recompute. Asserted RELATIONALLY and never as a literal digest.
{
  genAspects,
  genMerge,
  inputs,
}:
let
  c21Schema = inputs.gen.lib.substrate.schema;
  c21AspectSchema = genAspects.mkAspectSchema (import ../aspect-cnf.nix);
  c21Parent = {
    options.selvage = genMerge.mkOption {
      type = genMerge.types.str;
      default = "bound";
    };
  };
  c21ThimbleWith =
    compose:
    compose
    // {
      options.aspects = genMerge.mkOption {
        type = genMerge.types.listOf genMerge.types.str;
        default = [ ];
      };
      options.spool = genMerge.mkOption { type = genMerge.types.str; };
    };
  c21HeadSchema =
    (genMerge.evalModuleTree {
      modules = [
        { options.schema = c21AspectSchema.schemaOption; }
        (
          { config, ... }:
          {
            config.schema.hank = c21Parent;
            config.schema.thimble = c21ThimbleWith { imports = [ config.schema.hank ]; };
          }
        )
      ];
    }).config.schema;
  c21RelocatedSchema =
    compose:
    c21Schema.evalSchema {
      inherit (c21AspectSchema) schemaOption;
      modules = [
        {
          config.schema.hank = c21Parent;
          config.schema.thimble = c21ThimbleWith compose;
        }
      ];
    };
  c21Instance =
    kind:
    (genMerge.evalModuleTree {
      modules = [
        { imports = [ (c21AspectSchema.mkAspectModule { }) ]; }
        {
          options.thimbles = c21Schema.mkInstanceRegistry kind {
            extraModules = [
              {
                options.shirring = genMerge.mkOption {
                  type = genMerge.types.str;
                  default = "gathered";
                };
              }
            ];
          };
        }
        {
          config.thimbles.pewter = {
            aspects = [ "stitch" ];
            spool = "linen";
          };
        }
      ];
    }).config.thimbles.pewter;
  c21HeadKind = c21HeadSchema.thimble;
  c21RelocatedKind = (c21RelocatedSchema { inherits = [ "hank" ]; }).thimble;
  c21NoInheritKind = (c21RelocatedSchema { }).thimble;
  c21HeadInstance = c21Instance c21HeadKind;
  c21RelocatedInstance = c21Instance c21RelocatedKind;
  c21NoInheritInstance = c21Instance c21NoInheritKind;
in
{
  inherit
    c21Schema
    c21AspectSchema
    c21Parent
    c21ThimbleWith
    c21HeadSchema
    c21RelocatedSchema
    c21Instance
    c21HeadKind
    c21RelocatedKind
    c21NoInheritKind
    c21HeadInstance
    c21RelocatedInstance
    c21NoInheritInstance
    ;
}
