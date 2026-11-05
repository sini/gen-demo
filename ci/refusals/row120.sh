# shellcheck shell=bash
# ── row 120 -- an aspect body's undeclared key, BY NAME, with the aspect (C106, den-hoag-661s2) ──
# C106's cell holds that the misspelling is caught; tryEval cannot read which throw it caught, so the
# key and the aspect are read here. The unplanted arm spells the class right and serves a value, so a
# gate that refused every body key cannot pass it.
row120='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  gore = body: (merge.evalModuleTree {
    modules = [
      { options.aspects = (genAspects.mkAspectSchema (import ./aspect-cnf.nix)).mkAspectOption { }; }
      { aspects.gore = body; }
    ];
  }).config.aspects.gore;
  green = builtins.toJSON (genAspects.hasClassContent (gore { nixos.boot.loader.grub.enable = false; }).nixos);
  planted = builtins.deepSeq (gore { nixso.boot.loader.grub.enable = false; }).nixso "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row120 unplanted (a spelt class key keeps its content under the closed vocabulary)" \
  "${row120/BODY/green}" 0 "" "$tmpdir/row120-green.err" 'true'
check "T5 row120 planted   (a misspelt class key is refused by name, with its aspect)" \
  "${row120/BODY/planted}" 1 \
  "gen-aspects: aspect \`gore\`: undeclared aspect key 'nixso' (closed-key gate on; declare it in keySemantics or list it in freeformKeys)" \
  "$tmpdir/row120-planted.err"
check "T5 row120 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row120/BODY/caught}" 0 "" "$tmpdir/row120-catch.err" 'CAUGHT'
