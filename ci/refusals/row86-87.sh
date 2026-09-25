# shellcheck shell=bash
# ── rows 86/87 -- a kind is keyed by its MINTED identity, never its display name (den-hoag-l0y,
#    owner ruling (a), 2026-09-25) ──
# Two `thimble` kinds share a name and are two declarations (the second carries one more, non-key,
# option), so gen-schema's own `kindEq` calls them distinct. A name key conflated them: `sel.kind` of
# the first matched an instance of the second. Both kinds are minted through `mkSchemaOption` in the
# row's OWN tree, never imported from the corpus, so the plant cannot perturb the corpus's own
# declarations; the unplanted arms assert a STDOUT VALUE, so a library that refused everything, or
# never matched, cannot pass them.
# ★ TWO ROWS, because a kind NAME is refused at two different doors: the matcher, when a projection
# carries a name where the kind's key belongs (row86), and the registry adapter, when `kindFor`
# returns a name (row87). A name is a reference; resolving it needs the shared resolver.
rowIdentityHeader='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSelect = gen.lib.substrate.select;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  treeOf = extra: genMerge.evalModuleTree {
    modules = [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble.options = { spool = genMerge.mkOption { type = genMerge.types.str; }; } // extra; }
    ];
  };
  thimbleA = (treeOf { }).config.schema.thimble;
  thimbleB = (treeOf { notches = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; default = [ ]; }; }).config.schema.thimble;
  inst = genMerge.evalModuleTree {
    modules = [ {
      options.a = genSchema.mkInstanceRegistry thimbleA { };
      options.b = genSchema.mkInstanceRegistry thimbleB { };
      config.a.pewter.spool = "linen";
      config.b.pewter.spool = "linen";
    } ];
  };
  ctx = kindFor: genSelect.adapters.registry.mkContext {
    nodes = [ "a" "b" ]; data = id: if id == "a" then inst.config.a.pewter else inst.config.b.pewter;
    parent = _: null; inherit kindFor;
  };
  perId = id: if id == "a" then thimbleA else thimbleB;
  bareName = _: "thimble";
  valueCtx = ctx perId;
  nameCtx = { data = _: { __identity = { id_hash = "h"; kind = "thimble"; }; }; };
'
row86="${rowIdentityHeader}"'in builtins.toJSON (map (id: genSelect.matches (genSelect.kind thimbleA) id CTX) [ "a" "b" ])'
check "T5 row86 unplanted (the first thimble's selector matches its own instance and not the second's)" \
  "${row86/CTX/valueCtx}" 0 "" "$tmpdir/row86-green.err" '[true,false]'
check "T5 row86 planted   (a projection carrying the kind NAME where the kind's key belongs)" "${row86/CTX/nameCtx}" 1 \
  "gen-select: sel.kind matched against a projection whose __identity.kind for node a is the kind name" \
  "$tmpdir/row86-red.err"

row87="${rowIdentityHeader}"'in builtins.toJSON (genSelect.matches (genSelect.kind thimbleA) "a" (ctx ARG))'
check "T5 row87 unplanted (a kindFor returning the kind value answers)" "${row87/ARG/perId}" 0 "" \
  "$tmpdir/row87-green.err" 'true'
check "T5 row87 planted   (a kindFor returning the kind NAME)" "${row87/ARG/bareName}" 1 \
  'gen-select: adapters.registry.mkContext `kindFor` returned the kind name "thimble"; a kind name is a reference' \
  "$tmpdir/row87-red.err"
