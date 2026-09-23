# shellcheck shell=bash
# ── row 30 -- two DIFFERENT refinements of one base, merged with one silently dropped (gen-schema
#    oqrvg) ──
# The arc's class again, at the value level and fail-OPEN: a refined type's merge decision was taken
# on `functor.name`, which carries only the BASE, so declaring one option as two different
# refinements of `int` MERGED and kept one refinement. The other was gone with nothing said, and the
# value it forbade was then accepted. ADR-0034 rejects a name-only comparison anywhere it mints OR
# KEYS, and a merge decision keys.
# ★ THE TWO ARMS DIFFER BY ONE REFINEMENT RECORD on the second declaration -- the option, the base
# and the module shape are byte-identical on both. Nothing here is malformed.
# ★ THE UNPLANTED ARM ASSERTS A STDOUT VALUE, the surviving refinement's own message, so a library
# that refused every redeclaration cannot pass it; the planted arm's exit code is what a library
# refusing nothing cannot pass. The stderr substring proves a refusal FIRED, not WHICH one -- the
# relation's template interpolates the type's name and `refined` keeps the BASE's, so this string is
# byte-identical to the shipped bare-versus-refined refusal. Discrimination lives in gen-schema's
# own O2b table, never here.
row30='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  gauge = { check = self: self > 0 && self < 65536; message = "must be a valid gauge (1-65535)"; };
  slack = { check = self: self > 0; message = "must be slack"; };
  bolt = r: genMerge.mkOption { type = genSchema.refined genMerge.types.int [ r ]; };
in builtins.concatStringsSep "," (map (r: r.message) (genMerge.evalModuleTree {
  modules = [
    { options.gauge = bolt gauge; }
    { options.gauge = bolt SECONDREFINEMENT; }
  ];
}).options.gauge.type.__schema.refinements)'
check "T5 row30 unplanted (the SAME refinement declared twice, and the survivor is the assertion)" \
  "${row30/SECONDREFINEMENT/gauge}" 0 "" \
  "$tmpdir/row30-green.err" 'must be a valid gauge (1-65535)'
check "T5 row30 planted   (a SECOND, different refinement of the same base on the same option)" \
  "${row30/SECONDREFINEMENT/slack}" 1 \
  "which the first type's own \`functor' does not reconcile" \
  "$tmpdir/row30-red.err"

# ── row 30's second probe -- an identity DEMANDED of a sealed refined type ──
# The same defect one axis over: `__mint`/`__id` arrived verbatim from the base, so two different
# refinements of one base shared an identity WITH EACH OTHER AND WITH THE BARE BASE, and the demand
# still ANSWERED. ADR-0034 admits migrated or not-yet, and a silently-collapsing identity that
# answers is neither.
# ★ THE UNPLANTED ARM DEMANDS `__id` OF THE BARE BASE, which must still answer. That is what stops
# this row passing because gen-schema refuses everything, and it is the same digest the defect used
# to hand back for the REFINED type.
row30id='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
in SUBJECT.__id'
check "T5 row30id unplanted (the BARE base still mints, and the digest is the assertion)" \
  "${row30id/SUBJECT/genMerge.types.int}" 0 "" \
  "$tmpdir/row30id-green.err" 'type:d56681ac4aa3f64b427f9aceaab601fa2fe1e0db2cce50349be86f3fa0d886b6'
check "T5 row30id planted   (an identity demanded of a refinement over a caller predicate)" \
  "${row30id/SUBJECT/(genSchema.refined genMerge.types.int [ genSchema.refinements.tcpPort ])}" 1 \
  "identity: a lambda in an identity position" \
  "$tmpdir/row30id-red.err"
