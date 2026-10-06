# shellcheck shell=bash
# ── row 141 -- one aspect helper applied in two gen-aspects trees: an acyclic chain through its two
#    applications is refused by a text that names both readings and the remedy, and with the remedy it
#    composes (den-hoag-4i0o5; ADR-0025 item 1) ──
# The topology is C166's third tree (`kind-subsumption-across-trees`): framework <- consumer <- site,
# the consumer and the site each one application of a layer helper re-declaring `warp`. Untagged, the
# two applications share a content witness (the name, the source position, the parent names and the
# directly declared option names), which no reading before composition tells from a cycle, so the
# site's walk meets its own witness on the consumer and refuses. The planted arm pins the refusal's
# second reading and its remedy (the path-module clause included); the unplanted arm gives each application its own `_file` and asserts
# a STDOUT VALUE, so a reader that refused every layered chain cannot pass it.
row_one_aspect_helper_applied_in_two_gen_aspects_trees='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  int = merge.mkOption { type = merge.types.int; };
  ev = modules: (merge.evalModuleTree { } modules).config;
  framework = genAspects.mkAspectSchema { keySemantics.loom.category = "class"; };
  consumer = genAspects.mkAspectSchema { keySemantics = { loom.category = "class"; spindle.category = "class"; }; };
  fw = (ev [ { options.schema = framework.schemaOption; } { config.schema.aspect.options.weft = int; } ]).schema.aspect;
  layer = parent: { config.schema.aspect = { inherits = [ parent ]; options.warp = int; }; };
  layered = tag: parent: (ev [ { options.schema = consumer.schemaOption; } (layer parent // tag) ]).schema.aspect;
  chain = tag1: tag2: layered tag2 (layered tag1 fw);
  opts = k: builtins.concatStringsSep " " (builtins.attrNames k.options);
  green = opts (chain { _file = "aspect-layer:consumer"; } { _file = "aspect-layer:site"; });
  red = opts (chain { } { });
  caught = if (builtins.tryEval (builtins.deepSeq (chain { } { }).options null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 one-aspect-helper-applied-in-two-gen-aspects-trees unplanted (each application tagged with its own _file: the chain composes)" \
  "${row_one_aspect_helper_applied_in_two_gen_aspects_trees/BODY/green}" 0 "" "$tmpdir/one-aspect-helper-applied-in-two-gen-aspects-trees-green.err" 'warp weft'
check "T5 one-aspect-helper-applied-in-two-gen-aspects-trees planted   (untagged, the chain is refused naming both readings and the remedy)" \
  "${row_one_aspect_helper_applied_in_two_gen_aspects_trees/BODY/red}" 1 \
  "gen-schema: kind 'aspect' reaches a kind with its own content witness through its parents (aspect -> aspect), among kinds [aspect]: either it inherits itself, an inheritance cycle, and a kind may inherit only kinds resolved in a strictly earlier pass; or two kinds named 'aspect' were declared from one source with the same parent names and the same directly declared option names, which the witness does not tell apart before composition, and giving each such module its own \`_file\` separates them (a module imported by path is named by the \`_file\` its own content sets, else by its path; an importing module's \`_file\` does not reach it)" \
  "$tmpdir/one-aspect-helper-applied-in-two-gen-aspects-trees-red.err"
check "T5 one-aspect-helper-applied-in-two-gen-aspects-trees catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_one_aspect_helper_applied_in_two_gen_aspects_trees/BODY/caught}" 0 "" "$tmpdir/one-aspect-helper-applied-in-two-gen-aspects-trees-catch.err" 'CAUGHT'
