# shellcheck shell=bash
# ── row 117 -- a product COORDINATE of a sealed-only kind collision, refused by name at
#    `adapters.product.coord` (den-hoag-8hqx0; ADR-0034) ──
# Row 89's pair moved onto coordinates. Row 82's two `selvage` kinds (differing only in a refinement
# predicate, a caller lambda, so the field is sealed) mint ONE mark, so one `bolt` instance of each,
# at equal keys, carries ONE stamp. A coordinate decides an entity identity at one position, so
# `coord dim kind entry` now refuses the two coordinates by name, in `selectorEq` and in the match
# over a real gen-product space, where it used to call them equal on the stamp alone. The space is one
# `bolt` dimension over `endsP`'s registry, and its context carries `kinds.bolt = endsP`. The
# unplanted arms compare a coordinate with itself and match `b` on its own cell; the premise arm
# shows the two stamps ARE equal, so each planted refusal is decided at an equal stamp. Every
# addressing is bound here, in the prelude.
row117='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  sel = gen.lib.substrate.select;
  product = gen.lib.substrate.product;
  merge = gen.lib.modules.merge;
  P = sel.adapters.product;
  selvage = r: (merge.evalModuleTree { } [
    { options.schema = schema.mkSchemaOption { }; }
    { config.schema.selvage.options.ends = merge.mkOption { type = schema.refined merge.types.int r; }; }
  ]).config.schema.selvage;
  inRange = check: { inherit check; message = "must be in range"; };
  tcpLike = inRange (v: v > 0 && v < 65536);
  posLike = inRange (v: v > 0);
  ends = selvage tcpLike;
  endsP = selvage posLike;
  bolt = k: (merge.evalModuleTree { } [
    { options.r = schema.mkInstanceRegistry k { }; config.r.bolt.ends = 443; }
  ]).config.r.bolt;
  a = bolt ends;
  b = bolt endsP;
  space = product.productN "cartesian" [
    { dim = "bolt"; graph = { nodes = [ b.id_hash ]; edges = _: [ ]; parent = _: null; nodeData = _: b; }; }
  ];
  ctx = P.mkContext { cellIds = space.nodes; coordsFor = c: product.coordsOf c space; kinds.bolt = endsP; };
  cellB = builtins.head space.nodes;
  stampsEqual = a.id_hash == b.id_hash;
  unplanted = sel.selectorEq (P.coord "bolt" ends a) (P.coord "bolt" ends a);
  planted = sel.selectorEq (P.coord "bolt" ends a) (P.coord "bolt" endsP b);
  matchOwn = sel.matches (P.coord "bolt" endsP b) cellB ctx;
  matchPlanted = sel.matches (P.coord "bolt" ends a) cellB ctx;
in BODY'
check "T5 row117 premise   (the two coordinates carry one stamp)" \
  "${row117/BODY/builtins.toJSON stampsEqual}" 0 "" "$tmpdir/row117-premise.err" 'true'
check "T5 row117 unplanted (a coordinate compared with itself is one coordinate)" \
  "${row117/BODY/builtins.toJSON unplanted}" 0 "" "$tmpdir/row117-green.err" 'true'
check "T5 row117 unplanted (a coordinate matches its own cell of the space)" \
  "${row117/BODY/builtins.toJSON matchOwn}" 0 "" "$tmpdir/row117-own.err" 'true'
check "T5 row117 planted   (two coordinates of kinds differing only at a sealed field, refused by name)" \
  "${row117/BODY/builtins.toJSON planted}" 1 \
  "gen-select: selectorEq (adapters.product.coord): two declarations of 'selvage' mint one identity and are unequal only at sealed component(s) 'options.ends.type'" \
  "$tmpdir/row117-red.err"
check "T5 row117 planted   (the coordinate matched on the other kind's cell, refused by name)" \
  "${row117/BODY/builtins.toJSON matchPlanted}" 1 \
  "gen-select: adapters.product.coord: two declarations of 'selvage' mint one identity and are unequal only at sealed component(s) 'options.ends.type'" \
  "$tmpdir/row117-match-red.err"
check "T5 row117 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row117/BODY/if (builtins.tryEval planted).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row117-catch.err" 'CAUGHT'
