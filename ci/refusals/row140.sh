# shellcheck shell=bash
# ── row 140 -- a consumer `aspect` inheriting the framework's `aspect` BY VALUE: its refused twins
#    are refused BY NAME, catchably (den-hoag-l0y foreign-kind arm; ADR-0025 item 1) ──
# The topology is C166's (`kind-subsumption-across-trees`): two gen-aspects trees, the consumer's
# `aspect` inheriting the framework's `aspect` value, so the kind carries the name of the value it
# inherits. Before the reach step every reading of it aborted uncatchably (infinite recursion). Two
# plants: a consumer schema whose keySemantics omits the framework's class (the class check, which
# names the ancestor as the foreign kind value, since it carries the kind's own name), and a `//` copy
# of the framework kind (the completion stamp). The unplanted arm is the honest consumer and asserts a
# STDOUT VALUE, so a reader that refused every self-named kind cannot pass it.
row140='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  int = merge.mkOption { type = merge.types.int; };
  ev = modules: (merge.evalModuleTree { inherit modules; }).config;
  framework = genAspects.mkAspectSchema { keySemantics.loom.category = "class"; };
  both = { loom.category = "class"; spindle.category = "class"; };
  omitted = { spindle.category = "class"; };
  fw = (ev [ { options.schema = framework.schemaOption; } { config.schema.aspect.options.weft = int; } ]).schema.aspect;
  consumer = ks: parent: (ev [
    { options.schema = (genAspects.mkAspectSchema { keySemantics = ks; }).schemaOption; }
    { config.schema.aspect = { inherits = [ parent ]; options.warp = int; }; }
  ]).schema.aspect;
  opts = k: builtins.concatStringsSep " " (builtins.attrNames k.options);
  green = opts (consumer both fw);
  omitRed = opts (consumer omitted fw);
  copyRed = opts (consumer both (fw // { options = { }; }));
  caught = if (builtins.tryEval (builtins.deepSeq (consumer omitted fw).options null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row140 unplanted (the consumer aspect composes the framework aspect it inherits by value)" \
  "${row140/BODY/green}" 0 "" "$tmpdir/row140-green.err" 'warp weft'
check "T5 row140 planted   (a consumer schema omitting the framework class is refused by name)" \
  "${row140/BODY/omitRed}" 1 \
  "gen-schema: kind 'aspect' inherits the foreign kind value 'aspect', whose keySemantics declares the key 'loom', and this kind's keySemantics does not" \
  "$tmpdir/row140-omit.err"
check "T5 row140 planted   (a // copy of the framework aspect is refused by name)" \
  "${row140/BODY/copyRed}" 1 \
  "gen-schema: kind 'aspect' inherits: the kind value 'aspect' is not the value its schema built" \
  "$tmpdir/row140-copy.err"
check "T5 row140 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row140/BODY/caught}" 0 "" "$tmpdir/row140-catch.err" 'CAUGHT'
