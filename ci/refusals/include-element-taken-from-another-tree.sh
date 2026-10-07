# shellcheck shell=bash
# ── row 96 -- an include element taken from ANOTHER tree is refused BY NAME, catchably, apart from
#    inline content (den-hoag-ykt9t; ADR-0025 item 1) ──
# `graphFacts.unresolvedIncludesOf` published a by-value aspect whose key names no node of this tree
# at the same position list as inline content, so a broken reference read exactly like content. Every
# arm defines `app.includes` TWICE: an inline element's merge position is numbered per definition, so
# a library comparing it to the merged index refuses the unplanted arm, and a library publishing
# every element as content admits the planted one. The unplanted arm asserts a STDOUT VALUE, the
# edges of `app` in declared order: each inline element is an anonymous declaration keyed by its own
# definition's module (`a:2`, `a:3`; den-hoag-8hlo3), the member at 1 a reference, so a library
# refusing every element, or keying both literals by one position, cannot pass it. Every
# addressing is bound in the prelude: a `}` inside a `${row96/BODY/...}` replacement would end the
# expansion early.
row_include_element_taken_from_another_tree='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  schema = genAspects.mkAspectSchema { };
  mk = mods: genMerge.evalModuleTree { } ([ { options.schema = schema.schemaOption; } (schema.mkAspectModule { }) ] ++ mods);
  other = mk [ { config.aspects.elsewhere.thing = { }; } ];
  contentOnly = [ { description = "second"; } ];
  withOtherTree = [ { description = "second"; } other.config.aspects.elsewhere.thing ];
  tree = mk [
    ({ config, ... }: { config.aspects.hemline.placket = { }; config.aspects.app.includes = [ { description = "first"; } config.aspects.hemline.placket ]; })
    { config.aspects.app.includes = SECOND; }
  ];
  unresolved = (genAspects.graphFacts { } tree.config.aspects).unresolvedIncludesOf.app;
  shown = builtins.toJSON unresolved;
  edges = builtins.toJSON (genAspects.graphFacts { } tree.config.aspects).includesOf.app;
  caught = if (builtins.tryEval (builtins.deepSeq unresolved null)).success then "ADMITTED" else "CAUGHT";
in BODY'
row_include_element_taken_from_another_treeunplanted="${row_include_element_taken_from_another_tree/SECOND/contentOnly}"
row_include_element_taken_from_another_treeplanted="${row_include_element_taken_from_another_tree/SECOND/withOtherTree}"
check "T5 include-element-taken-from-another-tree unplanted (inline content over two definitions is two nodes, the member is an edge)" \
  "${row_include_element_taken_from_another_treeunplanted/BODY/edges}" 0 "" "$tmpdir/include-element-taken-from-another-tree-green.err" \
  '["app/includes/[\"a:2\",\"aspects\",\"app\",\"includes\",0]","hemline/placket","app/includes/[\"a:3\",\"aspects\",\"app\",\"includes\",0]"]'
check "T5 include-element-taken-from-another-tree planted   (another tree's aspect value is refused by name)" \
  "${row_include_element_taken_from_another_treeplanted/BODY/shown}" 1 \
  "declaration 'elsewhere/thing' is not a member of the registry (available: 'app', 'hemline', 'hemline/placket') (in prelude.resolve)" "$tmpdir/include-element-taken-from-another-tree-red.err"
check "T5 include-element-taken-from-another-tree catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_include_element_taken_from_another_treeplanted/BODY/caught}" 0 "" "$tmpdir/include-element-taken-from-another-tree-catch.err" 'CAUGHT'
