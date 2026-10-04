# shellcheck shell=bash
# ── row 135 -- a `//` copy of a kind value is refused BY NAME where the mark decides
#    (den-hoag-1a4f6; ADR-0034, ADR-0025 item 1) ──
# A kind value carries a completion stamp, `__kindSelf`, a function returning the value its schema
# built; a `//` copy keeps it, so the copy's witness returns the original and the copy is refused
# naming the kind. Three doors, each planted: `kindEq` (directly and through `types.anything`), the
# same-tree `inherits` NAME path, and the foreign `inherits` VALUE path. Every unplanted arm is the
# same expression with the `//` removed and asserts a STDOUT VALUE, so a door that refused every kind
# cannot pass it. C129 (`kind-value-swap-refused`) is this row's construct.
row135='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  int = merge.mkOption { type = merge.types.int; };
  tree = modules: (merge.evalModuleTree { } ([ { options.schema = schema.mkSchemaOption { }; } ] ++ modules)).config.schema;
  grommet = (tree [ { config.schema.grommet.options.eyelets = int; } ]).grommet;
  swap = k: k // { options = { }; };
  viaAnything = v: (merge.evalModuleTree { } [ { options.v = merge.mkOption { type = merge.types.anything; }; } { config.v = v; } ]).config.v;
  sameTree = f: (tree [
    { config.schema.grommet.options.eyelets = int; }
    ({ config, ... }: { config.schema.tab = { inherits = [ (f config.schema.grommet) ]; options.loop = int; }; })
  ]).tab;
  foreign = parent: (tree [ { config.schema.tab = { inherits = [ parent ]; options.loop = int; }; } ]).tab;
  opts = k: builtins.concatStringsSep " " (builtins.attrNames k.options);
  eqGreen = if schema.kindEq grommet (viaAnything grommet) then "same" else "other";
  eqRed = if schema.kindEq grommet (viaAnything (swap grommet)) then "same" else "other";
  nameGreen = opts (sameTree (g: g));
  nameRed = opts (sameTree swap);
  valueGreen = opts (foreign grommet);
  valueRed = opts (foreign (swap grommet));
  caught = if (builtins.tryEval (schema.kindEq grommet (swap grommet))).success then "ADMITTED" else "CAUGHT";
in BODY'
row135_msg="is not the value its schema built: a \`//\` over a kind value keeps its mark while changing what the mark stands for; declare the change in the kind entry, or pass the kind value the schema published"
check "T5 row135 unplanted (kindEq: the kind value through anything is itself)" \
  "${row135/BODY/eqGreen}" 0 "" "$tmpdir/row135-eq-green.err" 'same'
check "T5 row135 planted   (kindEq: a // copy through anything is refused by name)" \
  "${row135/BODY/eqRed}" 1 "gen-schema: kindEq: the kind value 'grommet' ${row135_msg}" "$tmpdir/row135-eq-red.err"
check "T5 row135 unplanted (inherits NAME path: the tree's own kind composes)" \
  "${row135/BODY/nameGreen}" 0 "" "$tmpdir/row135-name-green.err" 'eyelets loop'
check "T5 row135 planted   (inherits NAME path: a // copy of the tree's kind is refused by name)" \
  "${row135/BODY/nameRed}" 1 "gen-schema: kindEq: the kind value 'grommet' ${row135_msg}" "$tmpdir/row135-name-red.err"
check "T5 row135 unplanted (inherits VALUE path: a foreign kind composes)" \
  "${row135/BODY/valueGreen}" 0 "" "$tmpdir/row135-value-green.err" 'eyelets loop'
check "T5 row135 planted   (inherits VALUE path: a // copy of a foreign kind is refused by name)" \
  "${row135/BODY/valueRed}" 1 "gen-schema: kind 'tab' inherits: the kind value 'grommet' ${row135_msg}" "$tmpdir/row135-value-red.err"
check "T5 row135 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row135/BODY/caught}" 0 "" "$tmpdir/row135-catch.err" 'CAUGHT'
