# shellcheck shell=bash
# ── an include element writing `id` is refused BY NAME, catchably, at every door (den-hoag-l2yba; ADR-0034; ADR-0025 item 1) ──
# An include element is keyed by where it is declared, never by an `id` it writes. The vocabulary is opened
# here (`closedKeys = false`, gen-aspects' default): under the corpus's closed vocabulary the closed-key gate
# refuses an undeclared `id` already, for a different reason. Four doors are planted: a named and an unnamed
# literal (the type's stamp), a bare module `{ imports = [ … ]; }` (its own include member), and a literal in
# an instance's body (the reader of data the type never merged). The unplanted arm asserts a STDOUT VALUE: a
# reference to a node that itself carries an `id` datum keys as that node, a named element with no `id` keys
# under its owner's `includes`, and an instance body's element with no `id` keys under its instance, so a
# library refusing every element or every reference carrying an `id` attribute cannot pass it.
row_include_element_writing_id='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  cnf = import ./aspect-cnf.nix // { closedKeys = false; };
  tree = mod: (genMerge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      mod
    ]).config.aspects;
  el = e: builtins.head (tree { aspects.loom.includes = [ e ]; }).loom.includes;
  fired = e: map (s: s.target) (genAspects.includeSitesOfInstance { } (tree { }) { vertices.y.entry.includes = [ e ]; } "y");
  ref = builtins.head (tree ({ config, ... }: { aspects.bobbin = { id = "bobbin"; nixos.marks = [ "bobbin" ]; }; aspects.loom.includes = [ config.aspects.bobbin ]; })).loom.includes;
  named = genAspects.key (el { name = "heddle"; nixos.marks = [ "heddle" ]; });
  green = builtins.toJSON [ (genAspects.key ref) (builtins.substring 0 14 named) (fired { nixos.marks = [ "heddle" ]; }) ];
  plantedNamed = builtins.deepSeq (genAspects.key (el { name = "heddle"; id = "heddle"; nixos.marks = [ "heddle" ]; })) "SERVED";
  plantedUnnamed = builtins.deepSeq (genAspects.key (el { id = "heddle"; nixos.marks = [ "heddle" ]; })) "SERVED";
  plantedBare = builtins.deepSeq (genAspects.key (el { imports = [ { nixos.marks = [ "heddle" ]; } ]; id = "heddle"; })) "SERVED";
  plantedFired = builtins.deepSeq (fired { id = "heddle"; nixos.marks = [ "heddle" ]; }) "SERVED";
  caught = if builtins.any (p: (builtins.tryEval p).success) [ plantedNamed plantedUnnamed plantedBare plantedFired ] then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 include-element-writing-id unplanted (a reference to a node carrying an id keys as the node; elements with no id key under their owner and their instance)" \
  "${row_include_element_writing_id/BODY/green}" 0 "" "$tmpdir/include-element-writing-id-green.err" \
  '["bobbin","loom/includes/",["y/includes/0"]]'
check "T5 include-element-writing-id planted   (a named element writing id is refused by name)" \
  "${row_include_element_writing_id/BODY/plantedNamed}" 1 \
  "gen-aspects: an include element named \`heddle' writes \`id', which is reserved and keys nothing" \
  "$tmpdir/include-element-writing-id-named.err"
check "T5 include-element-writing-id planted   (an unnamed element writing id is refused by name)" \
  "${row_include_element_writing_id/BODY/plantedUnnamed}" 1 \
  "gen-aspects: an unnamed include element writes \`id', which is reserved and keys nothing" \
  "$tmpdir/include-element-writing-id-unnamed.err"
check "T5 include-element-writing-id planted   (a bare-module element writing id beside its imports is refused by name)" \
  "${row_include_element_writing_id/BODY/plantedBare}" 1 \
  "gen-aspects: an unnamed include element writes \`id', which is reserved and keys nothing" \
  "$tmpdir/include-element-writing-id-bare.err"
check "T5 include-element-writing-id planted   (an instance body's element writing id is refused by name where it is read)" \
  "${row_include_element_writing_id/BODY/plantedFired}" 1 \
  "gen-aspects.includes (aspect '<entry>', include position 0): an include element writes \`id', which is reserved on an include element" \
  "$tmpdir/include-element-writing-id-fired.err"
check "T5 include-element-writing-id catchable  (all four refusals are caught by tryEval, not an abort)" \
  "${row_include_element_writing_id/BODY/caught}" 0 "" "$tmpdir/include-element-writing-id-catch.err" 'CAUGHT'
