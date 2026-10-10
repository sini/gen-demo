# shellcheck shell=bash
# ── grammar-l1-renamed-exports -- the grammar's L1 renames are refused BY NAME, catchably, and each
#    refusal names its successor (den-hoag-7gp66 L1: R10 rule 3 and R8) ──
# gen-types' checkers are `checkedListOf`/`checkedAttrsOf`/`checkedOption` (gen-merge keeps
# `listOf`/`attrsOf`/`option` for its option types), gen-select's disjunction is `anyOf` (gen-prelude
# keeps `any`), gen-product's addressing doors are `nodeAt`/`nodeCoordinates` and its display helper is
# `show.node`, a nested export (den-hoag-o6b81). Each old name stays
# published as a tombstone. The unplanted arm builds through every successor and asserts a STDOUT
# VALUE (each arm's value is a string, as `nix eval --raw` coerces it), so a library that refused
# everything cannot pass it. Every addressing is bound in the prelude: a `}` inside a
# `${row/BODY/...}` replacement would end the expansion early.
row_grammar_l1_renamed_exports='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  inherit (gen.lib.substrate) select product graph;
  inherit (gen.lib.modules) types;
  reg = { sharp = { id_hash = "sharp"; name = "sharp"; }; };
  space = product.productN "cartesian" [ { dim = "needle"; graph = graph.fromRegistry { } (_: _: [ ]) reg; } ];
  green = builtins.toJSON [
    ((types.checkedListOf types.int).verify [ 1 ] == null)
    ((types.checkedAttrsOf types.int).verify { a = 1; } == null)
    ((types.checkedOption types.int).verify null == null)
    (select.anyOf [ select.star ]).__sel
    (product.coordsOf sharpAt space).needle.name
    (map (c: c.needle.name) (product.nodeCoordinates space))
    (product.show.node sharpCoords space)
  ];
  sharpCoords = builtins.head (product.nodeCoordinates space);
  sharpAt = product.nodeAt { needle = reg.sharp; } space;
  plantedListOf = types.listOf types.int;
  plantedAttrsOf = types.attrsOf types.int;
  plantedOption = types.option types.int;
  plantedAny = select.any [ select.star ];
  plantedCell = product.cell { needle = reg.sharp; } space;
  plantedCells = product.cells space;
  plantedShowCell = product.show.cell sharpCoords space;
  caught = builtins.toJSON (map (v: if (builtins.tryEval (builtins.typeOf v)).success then "ADMITTED" else "CAUGHT") [
    types.listOf types.attrsOf types.option select.any product.cell product.cells product.show.cell
  ]);
in BODY'
check "T5 grammar-l1-renamed-exports unplanted (every successor answers)" \
  "${row_grammar_l1_renamed_exports/BODY/green}" 0 "" "$tmpdir/grammar-l1-renamed-exports-green.err" \
  '[true,true,true,"any","sharp",["sharp"],"needle=sharp"]'
check "T5 grammar-l1-renamed-exports planted   (gen-types' listOf is refused and names checkedListOf)" \
  "${row_grammar_l1_renamed_exports/BODY/plantedListOf}" 1 \
  'gen-types: `listOf` is renamed `checkedListOf`.' "$tmpdir/grammar-l1-renamed-exports-listOf-red.err"
check "T5 grammar-l1-renamed-exports planted   (gen-types' attrsOf is refused and names checkedAttrsOf)" \
  "${row_grammar_l1_renamed_exports/BODY/plantedAttrsOf}" 1 \
  'gen-types: `attrsOf` is renamed `checkedAttrsOf`.' "$tmpdir/grammar-l1-renamed-exports-attrsOf-red.err"
check "T5 grammar-l1-renamed-exports planted   (gen-types' option is refused and names checkedOption)" \
  "${row_grammar_l1_renamed_exports/BODY/plantedOption}" 1 \
  'gen-types: `option` is renamed `checkedOption`.' "$tmpdir/grammar-l1-renamed-exports-option-red.err"
check "T5 grammar-l1-renamed-exports planted   (gen-select's any is refused and names anyOf)" \
  "${row_grammar_l1_renamed_exports/BODY/plantedAny}" 1 \
  'gen-select: `any` is renamed `anyOf`.' "$tmpdir/grammar-l1-renamed-exports-any-red.err"
check "T5 grammar-l1-renamed-exports planted   (gen-product's cell is refused and names nodeAt)" \
  "${row_grammar_l1_renamed_exports/BODY/plantedCell}" 1 \
  'gen-product: `cell` is renamed `nodeAt`.' "$tmpdir/grammar-l1-renamed-exports-cell-red.err"
check "T5 grammar-l1-renamed-exports planted   (gen-product's cells is refused and names nodeCoordinates)" \
  "${row_grammar_l1_renamed_exports/BODY/plantedCells}" 1 \
  'gen-product: `cells` is renamed `nodeCoordinates`.' "$tmpdir/grammar-l1-renamed-exports-cells-red.err"
check "T5 grammar-l1-renamed-exports planted   (gen-product's show.cell is refused and names show.node)" \
  "${row_grammar_l1_renamed_exports/BODY/plantedShowCell}" 1 \
  'gen-product: `show.cell` is renamed `show.node`.' "$tmpdir/grammar-l1-renamed-exports-show-cell-red.err"
check "T5 grammar-l1-renamed-exports catchable  (each refusal is caught by tryEval, not an abort)" \
  "${row_grammar_l1_renamed_exports/BODY/caught}" 0 "" "$tmpdir/grammar-l1-renamed-exports-catch.err" \
  '["CAUGHT","CAUGHT","CAUGHT","CAUGHT","CAUGHT","CAUGHT","CAUGHT"]'
