# shellcheck shell=bash
# ── a root read answers beside an incoherent root (gen-scope den-hoag-25mup) ──
# The refusing half of the cell of the same name, mirrored standalone: a hand-built record of `thimble` roots
# `a` and `b` whose kinds carry gen-schema kind values. Planted, `b` carries the `needle` kind's value, and
# its own read is refused by name, through `eval` and through `evalDebug`, naming the node and its kind. The
# unplanted arms are the same reads with `b` coherent, answering `b`, so a library refusing every hand-built
# kinded record cannot pass them.
row_a_root_read_answers_beside_an_incoherent_root='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  schema = (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { }; }
      { config.schema = {
          thimble.options.spool = genMerge.mkOption { type = genMerge.types.str; default = "linen"; };
          needle.options.eye = genMerge.mkOption { type = genMerge.types.str; default = "round"; };
        }; }
    ]).config.schema;
  kinds = genScope.mkKinds [
    (genScope.mkKind { kindValue = schema.needle; } "needle")
    (genScope.mkKind { kindValue = schema.thimble; below = [ "needle" ]; } "thimble")
  ];
  scope = {
    inherit kinds;
    nodeOrder = [ "a" "b" ];
    nodes = builtins.mapAttrs (id: kindValue: { inherit id kindValue; type = "thimble"; parent = null; decls = { }; }) {
      a = schema.thimble;
      b = schema.BVALUE;
    };
  };
in builtins.toJSON ((genScope.EVALUATOR { } { children = _: _: { }; } scope).node "b").id'
row_a_root_read_answers_beside_an_incoherent_root_eval="${row_a_root_read_answers_beside_an_incoherent_root/EVALUATOR/eval}"
row_a_root_read_answers_beside_an_incoherent_root_debug="${row_a_root_read_answers_beside_an_incoherent_root/EVALUATOR/evalDebug}"
check "T5 a-root-read-answers-beside-an-incoherent-root unplanted (b coherent: eval's node b answers)" "${row_a_root_read_answers_beside_an_incoherent_root_eval/BVALUE/thimble}" 0 "" \
  "$tmpdir/a-root-read-answers-beside-an-incoherent-root-green.err" '"b"'
check "T5 a-root-read-answers-beside-an-incoherent-root unplanted (b coherent: evalDebug's node b answers)" "${row_a_root_read_answers_beside_an_incoherent_root_debug/BVALUE/thimble}" 0 "" \
  "$tmpdir/a-root-read-answers-beside-an-incoherent-root-green-debug.err" '"b"'
check "T5 a-root-read-answers-beside-an-incoherent-root planted   (b carries the needle kind's value: eval's node b is refused by name)" "${row_a_root_read_answers_beside_an_incoherent_root_eval/BVALUE/needle}" 1 \
  "gen-scope.eval: node 'b' of kind 'thimble' carries a \`kindValue\` that is not the one its kind declares" \
  "$tmpdir/a-root-read-answers-beside-an-incoherent-root-red.err"
check "T5 a-root-read-answers-beside-an-incoherent-root planted   (b carries the needle kind's value: evalDebug's node b is refused by name)" "${row_a_root_read_answers_beside_an_incoherent_root_debug/BVALUE/needle}" 1 \
  "gen-scope.evalDebug: node 'b' of kind 'thimble' carries a \`kindValue\` that is not the one its kind declares" \
  "$tmpdir/a-root-read-answers-beside-an-incoherent-root-red-debug.err"
