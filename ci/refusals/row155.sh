# shellcheck shell=bash
# ── row 155 -- a closure in the result of a module function that a closure returned is refused BY NAME
#    at the gen-rules door (mirrors C198's `closure-returning-a-module-function`; den-hoag-zm0gu) ──
# The module system applies the returned function downstream, under arguments the door never holds, so a
# closure its result writes can be neither registered nor scoped. The planted arm writes a class closure
# over `bobbin` in that result, which base delivered without its guard; the unplanted arm writes none and
# asserts its class value, so a door that refused every module-function output cannot pass it.
row155='let
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
  load = genRules.defunctionalize { inherit cnf; declared = D; key = "row155"; lambdasPath = [ "lambdas" ]; aspectPaths = [ [ "aspects" ] ]; };
  received = cls:
    let
      tree = genMerge.evalModuleTree { } [
        { options.aspects = schema.mkAspectOption { }; }
        { options.lambdas = genRules.lambdas; }
        (load { aspects.main.includes = [ ({ thimble, ... }: { config, ... }: { nixos = cls; }) ]; })
      ];
      door = genRules.mkApply { inherit cnf; inherit (tree.config) lambdas; declared = D; };
      node = builtins.head (builtins.filter (x: builtins.isAttrs x && (x.__guard or false)) tree.config.aspects.main.includes);
      out = (genAspects.mkGuardVocab (cnf // { ref = door; })).applyGuardWith { context.thimble = "pewter"; sources = { }; scope = { }; } node;
    in
    (genMerge.evalModuleTree { } [ { options.aspects = schema.mkAspectOption { }; } { aspects.probe = out; } ]).config.aspects.probe;
  marker = m: (genMerge.evalModuleTree { } [
    { options.marker = genMerge.mkOption { type = genMerge.types.str; }; }
    { config._module.args.pkgs = "P"; }
    m
  ]).config.marker;
  plain = marker (received ({ pkgs, ... }: { marker = "plain-${pkgs}"; })).nixos;
  stitched = let p = received ({ bobbin, pkgs, ... }: { marker = "stitched-${bobbin}"; }); in
    builtins.deepSeq (map (x: builtins.isAttrs x && (x.__guard or false)) p.includes) "delivered";
in BODY'
check "T5 row155 unplanted (a module-function output holding no closure is served)" \
  "${row155/BODY/plain}" 0 "" "$tmpdir/row155-green.err" "plain-P"
check "T5 row155 planted   (a closure in a module-function output is refused by name at the door)" \
  "${row155/BODY/stitched}" 1 \
  "returned a module function whose result holds a closure at [\"nixos\"]; the door cannot register it" \
  "$tmpdir/row155-planted.err"
