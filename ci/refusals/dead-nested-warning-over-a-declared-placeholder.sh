# shellcheck shell=bash
# ── row 153 -- the dead-nested warning over a declared placeholder, under `abort-on-warn` (den-hoag-l62pz) ──
# `graphFacts` warns for a dead nested node whose id the cnf does not list in `freeformKeys`, and
# `builtins.warn` under `abort-on-warn` makes that warning fatal and uncatchable: a warning that fires
# on a CORRECT declaration therefore aborts the evaluation. `aspect-cnf.nix` lists C16's three
# placeholders by id, so the unplanted arm (C16's own placeholders, the real cnf) must evaluate and
# its stdout is the view's size, 3: a library that stopped computing the view, or a warning glue that
# says the whole view, cannot pass it. The planted arm adds one dead node the cnf does not list
# (`hemline/placket/nixso`, under a listed key so the closed-key gate admits it) and must abort naming it.
# The arms run as processes with the setting (`nixopts`): the setting is the evaluator's, not the expression's.
row_dead_nested_warning_over_a_declared_placeholder='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  cnf = import ./aspect-cnf.nix;
  facts = body: genAspects.graphFacts cnf (merge.evalModuleTree { } [
    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
    { aspects = body; }
  ]).config.aspects;
  placeholders = { hemline = { nixos.x = { }; placket.eyelet = { }; facing = { }; }; };
  green = toString (builtins.length (facts placeholders).deadNested);
  planted = toString (builtins.length (facts (placeholders // { hemline = placeholders.hemline // { placket = { eyelet = { }; nixso = { }; }; }; })).deadNested);
in BODY'
nixopts=(--option abort-on-warn true)
check "T5 dead-nested-warning-over-a-declared-placeholder unplanted (C16's declared placeholders evaluate under abort-on-warn, and the view still names the three)" \
  "${row_dead_nested_warning_over_a_declared_placeholder/BODY/green}" 0 "" "$tmpdir/dead-nested-warning-over-a-declared-placeholder-green.err" '3'
check "T5 dead-nested-warning-over-a-declared-placeholder planted   (a dead node the cnf does not list aborts, naming it)" \
  "${row_dead_nested_warning_over_a_declared_placeholder/BODY/planted}" 1 \
  "gen-aspects: nested aspect(s) \`hemline/placket/nixso\` deliver nothing" \
  "$tmpdir/dead-nested-warning-over-a-declared-placeholder-planted.err"
nixopts=()
