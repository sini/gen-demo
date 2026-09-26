# shellcheck shell=bash
# ── row 96 -- an include element taken from ANOTHER tree is refused BY NAME, catchably, apart from
#    inline content (den-hoag-ykt9t; ADR-0025 item 1) ──
# `graphFacts.unresolvedIncludesOf` published a by-value aspect whose key names no node of this tree
# at the same position list as inline content, so a broken reference read exactly like content. Every
# arm defines `app.includes` TWICE: an inline element's merge position is numbered per definition, so
# a library comparing it to the merged index refuses the unplanted arm, and a library publishing
# every element as content admits the planted one. The unplanted arm asserts a STDOUT VALUE (content
# at 0 and 2, the member at 1 an edge), so a library refusing every element cannot pass it. Every
# addressing is bound in the prelude: a `}` inside a `${row96/BODY/...}` replacement would end the
# expansion early.
row96='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  schema = genAspects.mkAspectSchema { };
  mk = mods: genMerge.evalModuleTree { modules = [ { options.schema = schema.schemaOption; } (schema.mkAspectModule { }) ] ++ mods; };
  other = mk [ { config.aspects.elsewhere.thing = { }; } ];
  contentOnly = [ { description = "second"; } ];
  withOtherTree = [ { description = "second"; } other.config.aspects.elsewhere.thing ];
  tree = mk [
    ({ config, ... }: { config.aspects.hemline.placket = { }; config.aspects.app.includes = [ { description = "first"; } config.aspects.hemline.placket ]; })
    { config.aspects.app.includes = SECOND; }
  ];
  unresolved = (genAspects.graphFacts { } tree.config.aspects).unresolvedIncludesOf.app;
  shown = builtins.toJSON unresolved;
  caught = if (builtins.tryEval (builtins.deepSeq unresolved null)).success then "ADMITTED" else "CAUGHT";
in BODY'
row96unplanted="${row96/SECOND/contentOnly}"
row96planted="${row96/SECOND/withOtherTree}"
check "T5 row96 unplanted (inline content over two definitions is published, the member is an edge)" \
  "${row96unplanted/BODY/shown}" 0 "" "$tmpdir/row96-green.err" '[0,2]'
check "T5 row96 planted   (another tree's aspect value is refused by name)" \
  "${row96planted/BODY/shown}" 1 \
  "names no node of this tree" "$tmpdir/row96-red.err"
check "T5 row96 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row96planted/BODY/caught}" 0 "" "$tmpdir/row96-catch.err" 'CAUGHT'
