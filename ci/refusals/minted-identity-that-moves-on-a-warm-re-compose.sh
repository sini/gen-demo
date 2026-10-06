# shellcheck shell=bash
# ── row 13 -- a minted identity that MOVES on a warm re-compose, refused by name (mirrors C17's
# closure from the other side) ──
#
# ★ IT IS A WARM RE-COMPOSE, NOT A COLD PLANT, AND THAT IS THE WHOLE ROW. Within ONE evaluation an
# identity simply is what it is; a move is only nameable where TWO evaluations are in hand, and the
# substrate holds two in exactly one place -- `warmFrom`. So this row builds the prior evaluation
# AND the warm re-compose in one expression, which is what makes a by-name refusal reachable from a
# single `nix eval` at all. A cold plant would exit 0 on BOTH arms and measure nothing.
#
# The edit is at a DECLARED identity position: `thimbles.pewter.spool`, an option of the `thimble`
# kind read through gen-schema's real registry (`evalSchema` + `mkInstanceRegistry`, the corpus's
# own crossing). The two arms are ONE token apart: `mkForce "linen"` re-defines the value the prior
# minted, so it is a dirty contribution at the identity position that moves nothing, and
# `mkForce "wool"` moves `pewter`. A refusal keyed on dirtiness alone would fire on BOTH arms and
# destroy reuse; the unplanted arm is what catches that, and its exact stdout is this row's thimble's
# unmoved stamp. It is not C17's `pewter` stamp: this row's `thimble` declares the corpus's option
# set without the corpus's `description`s, and gen-schema's kind mark carries each such attribute's
# path (den-hoag-egei0), so the two kinds mint apart. The control arm is the laziness witness: an
# edit that only declares an option nothing defines (`never`) is admitted warm without forcing it,
# the stamp unmoved.
#
# The row used to plant a KIND option (`grommet`) and rest its unplanted arm on `internal = true`
# excluding the option from identity. gen-schema no longer reads `internal` for identity -- it is
# presentation only, so an internal primitive is an identity key like any other -- and that arm
# stopped being a non-move. The refusal it pinned is unchanged.
row_minted_identity_that_moves_on_a_warm_re_compose='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
  schema = genSchema.evalSchema { schemaOption = aspectSchema.schemaOption; } [
      {
        config.schema.thimble.options.aspects = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; default = [ ]; };
        config.schema.thimble.options.spool = genMerge.mkOption { type = genMerge.types.str; };
      }
    ];
  outer = [
    { imports = [ (aspectSchema.mkAspectModule { }) ]; }
    { options.schema = genMerge.mkOption { type = genMerge.types.raw; default = schema; }; }
    { options.thimbles = genSchema.mkInstanceRegistry { } schema.thimble; }
    { config.thimbles.pewter = { aspects = [ "stitch" ]; spool = "linen"; }; }
  ];
  edit = [ EDIT ];
  prior = genMerge.evalModuleTree { } outer;
  warm = genMerge.evalModuleTree { warmFrom = prior; editedModules = edit; } (outer ++ edit);
in warm.config.thimbles.pewter.id_hash'
row_minted_identity_that_moves_on_a_warm_re_composestamp='thimble:7a784416ea03854bcbadc0dc9541834f6da5d6851dcc70eaf3dc9bd92b791199'
check "T5 minted-identity-that-moves-on-a-warm-re-compose unplanted (the declared spool re-defined to its minted value, no identity moves)" \
  "${row_minted_identity_that_moves_on_a_warm_re_compose/EDIT/{ config.thimbles.pewter.spool = genMerge.mkForce \"linen\"; \}}" 0 "" \
  "$tmpdir/minted-identity-that-moves-on-a-warm-re-compose-green.err" "$row_minted_identity_that_moves_on_a_warm_re_composestamp"
check "T5 minted-identity-that-moves-on-a-warm-re-compose planted   (the declared spool moved, pewter's identity moves)" \
  "${row_minted_identity_that_moves_on_a_warm_re_compose/EDIT/{ config.thimbles.pewter.spool = genMerge.mkForce \"wool\"; \}}" 1 \
  "gen-memo.identitiesHeld: minted identity moved on a warm re-compose at 'thimbles.pewter'" \
  "$tmpdir/minted-identity-that-moves-on-a-warm-re-compose-red.err"
check "T5 minted-identity-that-moves-on-a-warm-re-compose control   (an option nothing defines enters by edit, admitted without forcing it)" \
  "${row_minted_identity_that_moves_on_a_warm_re_compose/EDIT/{ options.never = genMerge.mkOption { type = genMerge.types.str; \}; \}}" 0 "" \
  "$tmpdir/minted-identity-that-moves-on-a-warm-re-compose-lazy.err" "$row_minted_identity_that_moves_on_a_warm_re_composestamp"
