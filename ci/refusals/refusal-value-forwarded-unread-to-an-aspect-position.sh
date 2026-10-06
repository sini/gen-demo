# shellcheck shell=bash
# ── row 144 -- a refusal value forwarded unread to an aspect position is refused BY NAME, naming its
#    encoding, its code and the gen-rules door (den-hoag-3sk7j; C175) ──
# gen-program's `admit 42` returns a refusal record with a flat witness, and its retired `escape` one
# with a nested witness. Placed in an aspect's `includes`, or at a root, each was admitted or refused
# by the unrelated orphan-leaf rule. The unplanted arm includes an aspect and asserts a STDOUT VALUE,
# its description, so a position that refused every include cannot pass it.
row_refusal_value_forwarded_unread_to_an_aspect_position='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  aspects = gen.lib.aspects.aspects;
  program = gen.lib.framework.program;
  merge = gen.lib.modules.merge;
  place = defs: (merge.evalModuleTree { } [
      { options.aspects = (aspects.mkAspectSchema { keySemantics.nixos.category = "class"; }).mkAspectOption { }; }
      { config.aspects = defs; }
    ]).config.aspects;
  escaped = program.escape { name = "tack"; emits = [ "selvage" ]; binds = [ "weft" ]; suppresses = [ ]; fn = { thimble, ... }: [ ]; };
  green = builtins.head (map (i: i.description) (place { selvage.includes = [ { description = "fringe"; } ]; }).selvage.includes);
  admitRed = builtins.deepSeq (place { selvage.includes = [ (program.admit 42) ]; }).selvage.includes "admitted";
  escapeRed = builtins.deepSeq (place { selvage.includes = [ escaped ]; }).selvage.includes "admitted";
  rootRed = builtins.deepSeq (place { selvage = program.admit 42; }).selvage "admitted";
  caught = if (builtins.tryEval (builtins.deepSeq (place { selvage = program.admit 42; }).selvage true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 refusal-value-forwarded-unread-to-an-aspect-position unplanted (an aspect in includes is admitted, its description read)" \
  "${row_refusal_value_forwarded_unread_to_an_aspect_position/BODY/green}" 0 "" "$tmpdir/refusal-value-forwarded-unread-to-an-aspect-position-green.err" 'fringe'
check "T5 refusal-value-forwarded-unread-to-an-aspect-position planted   (admit 42 in includes is refused by name, naming its encoding and code)" \
  "${row_refusal_value_forwarded_unread_to_an_aspect_position/BODY/admitRed}" 1 \
  "a refusal value reached an aspect position: a refusal record (\`{ refused = true; code; … }\`, gen-program) with code \`policy-body/skeleton-malformed\`, not an aspect." \
  "$tmpdir/refusal-value-forwarded-unread-to-an-aspect-position-admit.err"
check "T5 refusal-value-forwarded-unread-to-an-aspect-position planted   (the escape in includes is refused by name, not by orphan leaf)" \
  "${row_refusal_value_forwarded_unread_to_an_aspect_position/BODY/escapeRed}" 1 \
  "a refusal value reached an aspect position: a refusal record (\`{ refused = true; code; … }\`, gen-program) with code \`policy-body/escape-retired\`, not an aspect." \
  "$tmpdir/refusal-value-forwarded-unread-to-an-aspect-position-escape.err"
check "T5 refusal-value-forwarded-unread-to-an-aspect-position planted   (admit 42 at a root is refused naming the gen-rules door)" \
  "${row_refusal_value_forwarded_unread_to_an_aspect_position/BODY/rootRed}" 1 \
  "A context closure crosses the gen-rules door: declare the aspect through the framework's surface, so that gen-rules' lowering turns the closure into a door node, or write it as a guard term." \
  "$tmpdir/refusal-value-forwarded-unread-to-an-aspect-position-root.err"
check "T5 refusal-value-forwarded-unread-to-an-aspect-position catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_refusal_value_forwarded_unread_to_an_aspect_position/BODY/caught}" 0 "" "$tmpdir/refusal-value-forwarded-unread-to-an-aspect-position-catch.err" 'CAUGHT'
