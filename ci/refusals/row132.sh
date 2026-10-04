# shellcheck shell=bash
# ── row 132 -- a construction formal in a module the aspect kind entry IMPORTS, BY NAME (den-hoag-8x97u) ──
# Row 130's door reads the kind entry's own top level. Split the same write into an imported module,
# `config.schema.aspect.imports = [ { keySemantics = …; } ]`, and it used to land on every aspect as a
# nested aspect: gen-merge's collector read the imported module's top-level key as instance config.
# The entry's modules now carry the reservation, and the collector refuses the name naming the import
# route. The unplanted arm imports a module writing a declared extension, so a door that refused every
# imported key cannot pass it.
row132='let
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
  green = builtins.toJSON (gore { config.schema.aspect.imports = [ { priority = 7; } ]; }).priority;
  planted = builtins.deepSeq (builtins.attrNames (gore {
    config.schema.aspect.imports = [ { keySemantics = cnf.keySemantics // { darwin.category = "class"; }; } ];
  })) "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row132 unplanted (a declared extension written in a module the kind entry imports still reaches the aspect)" \
  "${row132/BODY/green}" 0 "" "$tmpdir/row132-green.err" '7'
check "T5 row132 planted   (a construction formal in a module the kind entry imports is refused by name)" \
  "${row132/BODY/planted}" 1 \
  "declaration key 'keySemantics' is a construction formal of this schema, written in a module this kind entry imports" \
  "$tmpdir/row132-planted.err"
check "T5 row132 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row132/BODY/caught}" 0 "" "$tmpdir/row132-catch.err" 'CAUGHT'
