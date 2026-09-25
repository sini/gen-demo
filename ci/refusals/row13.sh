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
# unmoved stamp. It is not C17's node: the stamp carries the kind's minted identity, and this row's
# `thimble` is its own declaration of the corpus's option set. The control arm is the laziness witness: an edit that only declares an
# option nothing defines (`never`) is admitted warm without forcing it, the stamp unmoved.
#
# The row used to plant a KIND option (`grommet`) and rest its unplanted arm on `internal = true`
# excluding the option from identity. gen-schema no longer reads `internal` for identity -- it is
# presentation only, so an internal primitive is an identity key like any other -- and that arm
# stopped being a non-move. The refusal it pinned is unchanged.
row13='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
  schema = genSchema.evalSchema {
    inherit (aspectSchema) schemaOption;
    modules = [
      {
        config.schema.thimble.options.aspects = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; default = [ ]; };
        config.schema.thimble.options.spool = genMerge.mkOption { type = genMerge.types.str; };
      }
    ];
  };
  outer = [
    { imports = [ (aspectSchema.mkAspectModule { }) ]; }
    { options.schema = genMerge.mkOption { type = genMerge.types.raw; default = schema; }; }
    { options.thimbles = genSchema.mkInstanceRegistry schema.thimble { }; }
    { config.thimbles.pewter = { aspects = [ "stitch" ]; spool = "linen"; }; }
  ];
  edit = [ EDIT ];
  prior = genMerge.evalModuleTree { modules = outer; };
  warm = genMerge.evalModuleTree { modules = outer ++ edit; warmFrom = prior; editedModules = edit; };
in warm.config.thimbles.pewter.id_hash'
row13stamp='thimble:705a5d2021c09cda5fed94157bda6b5446735fffe1f619375f90f930d10e7fd0'
check "T5 row13 unplanted (the declared spool re-defined to its minted value, no identity moves)" \
  "${row13/EDIT/{ config.thimbles.pewter.spool = genMerge.mkForce \"linen\"; \}}" 0 "" \
  "$tmpdir/row13-green.err" "$row13stamp"
check "T5 row13 planted   (the declared spool moved, pewter's identity moves)" \
  "${row13/EDIT/{ config.thimbles.pewter.spool = genMerge.mkForce \"wool\"; \}}" 1 \
  "gen-memo.identitiesHeld: minted identity moved on a warm re-compose at 'thimbles.pewter'" \
  "$tmpdir/row13-red.err"
check "T5 row13 control   (an option nothing defines enters by edit, admitted without forcing it)" \
  "${row13/EDIT/{ options.never = genMerge.mkOption { type = genMerge.types.str; \}; \}}" 0 "" \
  "$tmpdir/row13-lazy.err" "$row13stamp"
