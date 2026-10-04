# shellcheck shell=bash
# ── row 143 -- a kind inheriting one member of a cross-tree value cycle with distinct names is
#    refused by the member's name, catchably (den-hoag-1o0o1; ADR-0025 item 1) ──
# Two plain trees: `a` in one inherits `b` of the other by value, and `b` inherits `a`. A kind `k` of
# a third tree inherits `a`. `k` is not on the cycle, so its own walk answers nothing; it composes
# `a`, whose walk meets `a`'s witness, and refuses under `a`'s name. Before den-hoag-1o0o1 `k`'s
# completion-stamp read forced `a`'s classification of `b`, which re-entered `a` in flight, and nix
# and Determinate aborted uncatchably. The unplanted arm gives `b` a fresh parent instead, so `k`
# composes and asserts a STDOUT VALUE: a reader that refused every cross-tree value cannot pass it.
# Addressing as row 117, through `gen.lib.substrate.schema`.
row143='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  int = merge.mkOption { type = merge.types.int; };
  tree = modules: (merge.evalModuleTree { modules = [ { options.schema = schema.mkSchemaOption { }; } ] ++ modules; }).config.schema;
  kind = name: parent: o: { config.schema.${name} = { inherits = [ parent ]; options.${o} = int; }; };
  pairWith = bParent: let
    xA = tree [ (kind "a" xB.b "p") ];
    xB = tree [ (kind "b" (bParent xA.a) "q") ];
  in xA.a;
  fresh = (tree [ { config.schema.f.options.r = int; } ]).f;
  kOn = parent: (tree [ (kind "k" parent "ok") ]).k;
  opts = k: builtins.concatStringsSep " " (builtins.attrNames k.options);
  green = opts (kOn (pairWith (_: fresh)));
  red = opts (kOn (pairWith (a: a)));
  caught = if (builtins.tryEval (builtins.deepSeq (kOn (pairWith (a: a))).options null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row143 unplanted (b inherits a fresh kind: k composes a, b and its own option)" \
  "${row143/BODY/green}" 0 "" "$tmpdir/row143-green.err" 'ok p q r'
check "T5 row143 planted   (a and b inherit each other across trees: k is refused by a's name)" \
  "${row143/BODY/red}" 1 \
  "gen-schema: kind 'a' reaches a kind with its own content witness through its parents (a -> b -> a), among kinds [a b]: either it inherits itself, an inheritance cycle" \
  "$tmpdir/row143-red.err"
check "T5 row143 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row143/BODY/caught}" 0 "" "$tmpdir/row143-catch.err" 'CAUGHT'
