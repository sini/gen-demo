# ── C21 — THE CORPUS'S IDENTITY STAMP SURVIVES THE SCHEMA-INHERITANCE RELOCATION ──
# (ADR-0016 ruling 7, ADR-0033). §2.6 of the relocation moved every kind declaration off the
# live `config.schema.<k>` crossing and onto gen-schema's staged `evalSchema` pass, where a
# parent travels as a NAME instead of being read out of the tree being declared. The corpus's
# own stamp must not move across that rewrite — and the oracle must be able to SEE it move,
# or the equality is two agreeing arms measuring nothing.
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
# `spool` against `name`/`spool`) and the stamp genuinely moves when the inheritance goes. The
# no-inherit arm lands on
# `thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a` — the corpus's own
# published stamp, the one `ci/refusals.sh` row 13 pins — which is what shows this instrument
# is the corpus's and not a lookalike built beside it.
#
# Asserted RELATIONALLY and never as a literal digest: the digests this pair was designed
# against were measured at a different lock, and pinning one here would relay a figure across
# a rev boundary.
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
  c21Stamp =
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
    }).config.thimbles.pewter.id_hash;
  c21HeadIdhash = c21Stamp c21HeadSchema.thimble;
  c21RelocatedIdhash = c21Stamp (c21RelocatedSchema { inherits = [ "hank" ]; }).thimble;
  c21NoInheritIdhash = c21Stamp (c21RelocatedSchema { }).thimble;
in
{
  inherit
    c21Schema
    c21AspectSchema
    c21Parent
    c21ThimbleWith
    c21HeadSchema
    c21RelocatedSchema
    c21Stamp
    c21HeadIdhash
    c21RelocatedIdhash
    c21NoInheritIdhash
    ;
}
