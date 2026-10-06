# shellcheck shell=bash
# ── row 130 -- a construction formal written on the aspect kind entry, BY NAME (den-hoag-q17cc) ──
# `config.schema.aspect.keySemantics = …` reads like widening the class vocabulary. It used to land on
# every aspect as a nested aspect while the schema's own keySemantics stayed what `mkAspectSchema` was
# given, and under the corpus's closed keys the only text an author met pointed back at keySemantics.
# The unplanted arm writes a declared extension as shorthand on the same entry, so a door that refused
# every top-level key cannot pass it.
row_construction_formal_written_on_the_aspect_kind_entry='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  cnf = import ./aspect-cnf.nix;
  schema = genAspects.mkAspectSchema cnf;
  gore = extra: (merge.evalModuleTree { } [
      (schema.mkAspectModule { })
      { options.schema = schema.schemaOption; }
      { config.schema.aspect.options.priority = merge.mkOption { type = merge.types.int; default = 0; }; }
      { config.aspects.gore.nixos = { }; }
      extra
    ]).config.aspects.gore;
  green = builtins.toJSON (gore { config.schema.aspect.priority = 7; }).priority;
  planted = builtins.deepSeq (builtins.attrNames (gore {
    config.schema.aspect.keySemantics = cnf.keySemantics // { darwin.category = "class"; };
  })) "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 construction-formal-written-on-the-aspect-kind-entry unplanted (a declared extension written on the kind entry still reaches the aspect)" \
  "${row_construction_formal_written_on_the_aspect_kind_entry/BODY/green}" 0 "" "$tmpdir/construction-formal-written-on-the-aspect-kind-entry-green.err" '7'
check "T5 construction-formal-written-on-the-aspect-kind-entry planted   (a construction formal written on the kind entry is refused by name)" \
  "${row_construction_formal_written_on_the_aspect_kind_entry/BODY/planted}" 1 \
  "declaration key 'keySemantics' is a construction formal" \
  "$tmpdir/construction-formal-written-on-the-aspect-kind-entry-planted.err"
check "T5 construction-formal-written-on-the-aspect-kind-entry catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_construction_formal_written_on_the_aspect_kind_entry/BODY/caught}" 0 "" "$tmpdir/construction-formal-written-on-the-aspect-kind-entry-catch.err" 'CAUGHT'
