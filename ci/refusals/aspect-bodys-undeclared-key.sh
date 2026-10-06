# shellcheck shell=bash
# ── row 127 -- an aspect body's undeclared key, BY NAME, with the aspect (C111, den-hoag-661s2) ──
# C111's cell holds that the misspelling is caught; tryEval cannot read which throw it caught, so the
# key and the aspect are read here. The unplanted arm spells the class right and serves a value, so a
# gate that refused every body key cannot pass it.
row_aspect_bodys_undeclared_key='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  gore = body: (merge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema (import ./aspect-cnf.nix)).mkAspectOption { }; }
      { aspects.gore = body; }
    ]).config.aspects.gore;
  green = builtins.toJSON (genAspects.hasClassContent (gore { nixos.boot.loader.grub.enable = false; }).nixos);
  planted = builtins.deepSeq (gore { nixso.boot.loader.grub.enable = false; }).nixso "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 aspect-bodys-undeclared-key unplanted (a spelt class key keeps its content under the closed vocabulary)" \
  "${row_aspect_bodys_undeclared_key/BODY/green}" 0 "" "$tmpdir/aspect-bodys-undeclared-key-green.err" 'true'
check "T5 aspect-bodys-undeclared-key planted   (a misspelt class key is refused by name, with its aspect)" \
  "${row_aspect_bodys_undeclared_key/BODY/planted}" 1 \
  "gen-aspects: aspect \`gore\`: undeclared aspect key 'nixso' (closed-key gate on; declare it in keySemantics or list it in freeformKeys)" \
  "$tmpdir/aspect-bodys-undeclared-key-planted.err"
check "T5 aspect-bodys-undeclared-key catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_aspect_bodys_undeclared_key/BODY/caught}" 0 "" "$tmpdir/aspect-bodys-undeclared-key-catch.err" 'CAUGHT'
