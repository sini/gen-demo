# shellcheck shell=bash
# ── row 142 -- a deferred `declarationOf "<kind>"` that no registry binds is refused BY NAME,
#    catchably, and so is a `setOf` of it (den-hoag-registry-types-outside-kind-d24lq; C87) ──
# C87's types on plain options with no `refs.<field>` binding: there is no scope to resolve a
# reference in, so the value is refused rather than served raw. The unplanted arm binds the same type
# through `mkInstanceRegistry` and asserts a STDOUT VALUE, the resolved declaration's field, so a
# schema that refused every deferred declaration cannot pass it. Every addressing is bound in the
# prelude: a `}` inside a `${row142/BODY/...}` replacement would end the expansion early.
row_deferred_declarationof_kind_that_no_registry_binds='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  kinds = schema.evalSchema { } [
      {
        config.schema.aglet.options.finish = merge.mkOption { type = merge.types.str; };
        config.schema.lacet.options.tip = merge.mkOption { type = schema.declarationOf "aglet"; };
      }
    ];
  bound = merge.evalModuleTree { } [
      {
        options.aglets = schema.mkInstanceRegistry { } kinds.aglet;
        options.lacets = schema.mkInstanceRegistry { refs.tip = bound.config.aglets; } kinds.lacet;
        config.aglets.gilt.finish = "gilded";
        config.lacets.l.tip = "gilt";
      }
    ];
  unbound = (merge.evalModuleTree { } [
      {
        options.tip = merge.mkOption { type = schema.declarationOf "aglet"; };
        options.spares = merge.mkOption { type = schema.setOf (schema.declarationOf "aglet"); };
        config.tip = "gilt";
        config.spares = [ "gilt" "gilt" ];
      }
    ]).config;
  green = bound.config.lacets.l.tip.finish;
  tipRed = builtins.seq unbound.tip "admitted";
  sparesRed = builtins.deepSeq unbound.spares "admitted";
  caught = if (builtins.tryEval (builtins.deepSeq unbound.spares true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 deferred-declarationof-kind-that-no-registry-binds unplanted (a bound deferred declaration resolves to the registry entry)" \
  "${row_deferred_declarationof_kind_that_no_registry_binds/BODY/green}" 0 "" "$tmpdir/deferred-declarationof-kind-that-no-registry-binds-green.err" 'gilded'
check "T5 deferred-declarationof-kind-that-no-registry-binds planted   (an unbound declarationOf is refused by name)" \
  "${row_deferred_declarationof_kind_that_no_registry_binds/BODY/tipRed}" 1 \
  "gen-schema: tip: \`declarationOf \"aglet\"' is unbound here. A deferred declaration resolves only through a registry binding" \
  "$tmpdir/deferred-declarationof-kind-that-no-registry-binds-tip.err"
check "T5 deferred-declarationof-kind-that-no-registry-binds planted   (an unbound setOf is refused at its first element, in the element's words)" \
  "${row_deferred_declarationof_kind_that_no_registry_binds/BODY/sparesRed}" 1 \
  "\`declarationOf \"aglet\"' is unbound here. A deferred declaration resolves only through a registry binding" \
  "$tmpdir/deferred-declarationof-kind-that-no-registry-binds-spares.err"
check "T5 deferred-declarationof-kind-that-no-registry-binds catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_deferred_declarationof_kind_that_no_registry_binds/BODY/caught}" 0 "" "$tmpdir/deferred-declarationof-kind-that-no-registry-binds-catch.err" 'CAUGHT'
