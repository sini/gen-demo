# shellcheck shell=bash
# ── functor-context-closure-at-an-aspect-position -- an attrset whose `__functor` yields a context closure,
#    unlowered at an aspect position, is refused BY NAME, where it was read as config and delivered nothing
#    (den-hoag-iy9qh) ──
# A submodule reads an attrset definition as config, so the functor's `__functor` key landed in the
# aspect's freeform slot and nothing fired. The planted arm writes that shape at an aspect with no loader;
# the unplanted arm writes its lambda twin through gen-rules' loader, which lowers it to a door node that
# fires, so a type that refused every closure cannot pass it. The catchable arm writes a malformed functor
# (its `__functor` yields no lambda) at a class key, which the loader once read with builtin
# `functionArgs` and aborted on, past `tryEval`.
row_functor_context_closure_at_an_aspect_position='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genRules = gen.lib.framework.rules;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  inherit (gen.lib.substrate.identity) hashIdentity;
  D = [ "thimble" "bobbin" ];
  cnf = {
    entityKinds = D;
    keySemantics.nixos.category = "class";
    moduleArgs = { config = true; pkgs = true; };
    aspectModules = [ (genRules.lambdasMount "lambdas") ];
  };
  schema = genAspects.mkAspectSchema cnf;
  load = genRules.defunctionalize { inherit cnf; declared = D; key = "row_functor_context_closure_at_an_aspect_position"; lambdasPath = [ "lambdas" ]; aspectPaths = [ [ "aspects" ] ]; };
  fn = { thimble, ... }: { description = "hem-${thimble}"; };
  tree = mods:
    (genMerge.evalModuleTree { } ([
      { options.aspects = schema.mkAspectOption { }; }
      { options.lambdas = genRules.lambdas; }
    ] ++ mods)).config;
  lowered = tree [ (load { aspects.hem.includes = [ fn ]; }) ];
  door = genRules.mkApply { inherit (lowered) lambdas; inherit cnf; declared = D; };
  vocab = genAspects.mkGuardVocab (cnf // { ref = door; });
  node = builtins.head (builtins.filter (x: builtins.isAttrs x && (x.__guard or false)) lowered.aspects.hem.includes);
  twin = (vocab.applyGuardWith { context.thimble = "pewter"; sources.thimble = hashIdentity "entity" [ "name" ] (_: "pewter"); scope = { }; } node).description;
  functor = builtins.deepSeq (tree [ { aspects.hem = { __functor = _: fn; }; } ]).aspects.hem.description "delivered";
  malformed = (tree [ (load { aspects.hem.nixos = { __functor = _: 5; }; }) ]).aspects.hem;
  caught = if (builtins.tryEval (builtins.deepSeq [ malformed.nixos malformed.includes ] null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 functor-context-closure-at-an-aspect-position unplanted (the lambda twin is lowered by the loader and fires)" \
  "${row_functor_context_closure_at_an_aspect_position/BODY/twin}" 0 "" "$tmpdir/functor-context-closure-at-an-aspect-position-green.err" 'hem-pewter'
check "T5 functor-context-closure-at-an-aspect-position planted   (a functor context closure at an aspect is refused by name)" \
  "${row_functor_context_closure_at_an_aspect_position/BODY/functor}" 1 \
  'an attrset whose `__functor` yields a context closure reached an aspect position' \
  "$tmpdir/functor-context-closure-at-an-aspect-position-planted.err"
check "T5 functor-context-closure-at-an-aspect-position catchable  (a malformed functor at a class key is refused, not an abort)" \
  "${row_functor_context_closure_at_an_aspect_position/BODY/caught}" 0 "" "$tmpdir/functor-context-closure-at-an-aspect-position-catch.err" 'CAUGHT'
