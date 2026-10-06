# shellcheck shell=bash
# ── row 161 -- a class-key closure under an override or order wrapper is refused BY NAME at the gen-rules
#    loader (mirrors C201's `wrapped-closure-is-lowered-as-unwrapped`; den-hoag-crk5e) ──
# The lift moves a class-key closure into `includes`, so a rank written on it (`mkForce`, `mkBefore`, …)
# would rank it against other definitions than the ones it was written beside. The planted arm writes
# `nixos = mkForce <closure over bobbin>`, which base delivered with its guard dropped; the unplanted arm
# writes the same closure under `mkIf true` and asserts its lifted node's guard, so a loader that refused
# every wrapped class closure cannot pass it.
row_class_key_closure_under_an_override_or_order_wrapper='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genRules = gen.lib.framework.rules;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  D = [ "thimble" "bobbin" ];
  cnf = {
    entityKinds = D;
    keySemantics.nixos.category = "class";
    moduleArgs = { config = true; pkgs = true; };
    aspectModules = [ (genRules.lambdasMount "lambdas") ];
  };
  schema = genAspects.mkAspectSchema cnf;
  load = genRules.defunctionalize { inherit cnf; declared = D; key = "row_class_key_closure_under_an_override_or_order_wrapper"; lambdasPath = [ "lambdas" ]; aspectPaths = [ [ "aspects" ] ]; };
  main = wrap:
    (genMerge.evalModuleTree { } [
      { options.aspects = schema.mkAspectOption { }; }
      { options.lambdas = genRules.lambdas; }
      (load { aspects.main.nixos = wrap ({ bobbin, pkgs, ... }: { marker = "seam-${bobbin}"; }); })
    ]).config.aspects.main;
  guards = a: builtins.filter (x: builtins.isAttrs x && (x.__guard or false)) a.includes;
  plain = builtins.concatStringsSep "," (builtins.concatMap (n: map (i: i.name) n.condition.items) (guards (main (genMerge.mkIf true))));
  ranked = builtins.deepSeq (main genMerge.mkForce).nixos "delivered";
in BODY'
check "T5 class-key-closure-under-an-override-or-order-wrapper unplanted (a class-key closure under mkIf is lifted with its guard)" \
  "${row_class_key_closure_under_an_override_or_order_wrapper/BODY/plain}" 0 "" "$tmpdir/class-key-closure-under-an-override-or-order-wrapper-green.err" "bobbin"
check "T5 class-key-closure-under-an-override-or-order-wrapper planted   (a class-key closure under mkForce is refused by name at the loader)" \
  "${row_class_key_closure_under_an_override_or_order_wrapper/BODY/ranked}" 1 \
  'at a class key under a property wrapper of `_type = "override"`' \
  "$tmpdir/class-key-closure-under-an-override-or-order-wrapper-planted.err"
