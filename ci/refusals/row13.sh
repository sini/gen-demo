# shellcheck shell=bash
# ── row 13 -- a KIND option contributed after an evaluation already minted, refused on the WARM
# re-compose (mirrors C17's closure from the other side) ──
#
# ★ IT IS A WARM RE-COMPOSE, NOT A COLD PLANT, AND THAT IS THE WHOLE ROW. Region 1 closes the
# INSTANCE side by construction, so an instance-side option is unexpressible in an identity rather
# than refused -- there is nothing for a by-name row to catch there, and C17 asserts it as a value
# instead. The KIND side has no such construction: within ONE evaluation a kind's option set simply
# is what it is. The move is only nameable where TWO evaluations are in hand, and the substrate
# holds two in exactly one place -- `warmFrom`. So this row builds the prior evaluation AND the
# warm re-compose in one expression, which is what makes a by-name refusal reachable from a single
# `nix eval` at all. A cold plant would exit 0 on BOTH arms and measure nothing.
#
# The two arms are ONE token apart: `internal = true` makes the planted option a declaration the
# identity reflection excludes, so it is still a dirty decl-side contribution -- the id_hash is
# re-merged either way -- and moves nothing. A refusal keyed on decl-side dirtiness alone would
# fire on BOTH arms and destroy reuse; the unplanted arm is what catches that, and its exact
# stdout is the corpus's own unmoved thimble stamp.
#
# ★ THE CROSSING SPELLING MIGRATED (2026-09-15 relocation, §2.6): the kind is read through the
# staged `evalSchema` pass now, same as the corpus's own `gen-modules/corpus.nix`, not off a bare
# `config.schema.thimble`. `evalSchema` has no `warmFrom` of its own to thread -- it runs its OWN
# internal `evalModuleTree`, sealed before the outer tree below ever starts -- so "prior" and
# "warm" each get their OWN `evalSchema` call over the kind's own module list (unplanted / with
# `grommet` planted), and it is the OUTER tree's `mkInstanceRegistry <schema>.thimble` declaration
# that differs between the two, which is what the outer `warmFrom` compares. Driven both arms:
# green still exits 0 with the unmoved stamp; red still carries gen-memo's own by-name refusal.
row13='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
  kindModules = extra: [
    {
      config.schema.thimble.options.aspects = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; default = [ ]; };
      config.schema.thimble.options.spool = genMerge.mkOption { type = genMerge.types.str; };
    }
  ] ++ extra;
  mkOuter = schema: [
    { imports = [ (aspectSchema.mkAspectModule { }) ]; }
    { options.schema = genMerge.mkOption { type = genMerge.types.raw; default = schema; }; }
    ({ config, ... }: { options.thimbles = genSchema.mkInstanceRegistry schema.thimble { }; })
    { config.thimbles.pewter = { aspects = [ "stitch" ]; spool = "linen"; }; }
  ];
  priorSchema = genSchema.evalSchema { inherit (aspectSchema) schemaOption; modules = kindModules [ ]; };
  warmSchema = genSchema.evalSchema {
    inherit (aspectSchema) schemaOption;
    modules = kindModules [ { config.schema.thimble.options.grommet = genMerge.mkOption { type = genMerge.types.str; default = "plain"; internal = INTERNAL; }; } ];
  };
  prior = genMerge.evalModuleTree { modules = mkOuter priorSchema; };
  warmBase = mkOuter warmSchema;
  warm = genMerge.evalModuleTree { modules = warmBase; warmFrom = prior; editedModules = warmBase; };
in warm.config.thimbles.pewter.id_hash'
check "T5 row13 unplanted (planted option internal, no identity moves)" "${row13/INTERNAL/true}" 0 "" \
  "$tmpdir/row13-green.err" 'thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a'
check "T5 row13 planted   (planted option is an identity key, pewter moves)" "${row13/INTERNAL/false}" 1 \
  "gen-memo.identitiesHeld: minted identity moved on a warm re-compose at 'thimbles.pewter'" \
  "$tmpdir/row13-red.err"
