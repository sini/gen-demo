# shellcheck shell=bash
# ── row 122 -- the warm walk's two refusals over a nixpkgs module set, BY NAME (C108,
#    den-hoag-drxbc) ──
# C108's cell holds that each is caught; tryEval cannot read which throw it caught, so the name is
# read here. A nixpkgs `deferredModuleWith` whose static modules declare `id_hash` places an instance
# at its position and holds a module there: the walk refuses the read, naming the door and the
# option. A nixpkgs `submodule` holds its instance at its position, and a move of it is gen-memo's
# refusal, not the walk's, so C108's control cannot pass on the walk's throw. The unplanted arm is a
# `listOf` stripped of its `nestedTypes`, which holds its instances below its position and serves the
# moved value, so a walk that refused every nixpkgs module set cannot pass it.
row122='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  merge = gen.lib.modules.merge;
  t = gen.inputs.nixpkgs.lib.types;
  spoolMod = { config, ... }: {
    options.id_hash = merge.mkOption { type = merge.types.str; };
    options.spool = merge.mkOption { type = merge.types.str; default = ""; };
    config.id_hash = "bobbin:" + builtins.hashString "sha256" config.spool;
  };
  base = ty: v: [
    { options.reel = merge.mkOption { type = merge.types.attrsOf (merge.types.submodule spoolMod); }; }
    { _file = "anchor"; config.reel.a.spool = "anchor"; }
    { options.skein = merge.mkOption { type = ty; }; }
    { _file = "base"; config.skein = v; }
  ];
  warm = ty: v: v2: let edit = [ { _file = "edit"; config.skein = merge.mkForce v2; } ]; in
    (merge.evalModuleTree {
      modules = base ty v ++ edit;
      warmFrom = merge.evalModuleTree { modules = base ty v; };
      editedModules = edit;
    }).config;
  green = builtins.toJSON (map (x: x.spool) (warm (t.listOf (t.submodule spoolMod) // { nestedTypes = { }; }) [ { spool = "silk"; } ] [ { spool = "satin"; } ]).skein);
  deferred = builtins.deepSeq (warm (t.deferredModuleWith { staticModules = [ spoolMod ]; }) { spool = "silk"; } { spool = "satin"; }).reel "SERVED";
  moved = builtins.deepSeq (warm (t.submodule spoolMod) { spool = "silk"; } { spool = "satin"; }).reel "SERVED";
  caught = if (builtins.tryEval deferred).success || (builtins.tryEval moved).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row122 unplanted (a stripped listOf holds its instances below its position and serves)" \
  "${row122/BODY/green}" 0 "" "$tmpdir/row122-green.err" '["satin"]'
check "T5 row122 planted   (a module where an instance is declared is refused by name)" \
  "${row122/BODY/deferred}" 1 \
  "gen-merge: \`evalModuleTree' at option \`skein': the warm identity walk reads the option as an instance (its declaration declares \`id_hash'), and the value there is a set without \`id_hash'" \
  "$tmpdir/row122-deferred.err"
check "T5 row122 planted   (a moved nixpkgs submodule instance is gen-memo's refusal, not the walk's)" \
  "${row122/BODY/moved}" 1 \
  "gen-memo.identitiesHeld: minted identity moved on a warm re-compose at 'skein'" \
  "$tmpdir/row122-moved.err"
check "T5 row122 catchable  (both refusals are caught by tryEval, not an abort)" \
  "${row122/BODY/caught}" 0 "" "$tmpdir/row122-catch.err" 'CAUGHT'
