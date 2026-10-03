# shellcheck shell=bash
# ── row 142 -- a deferred `declarationOf "<kind>"` that no registry binds is refused BY NAME,
#    catchably, and so is a `setOf` of it (den-hoag-registry-types-outside-kind-d24lq; C87) ──
# C87's types on plain options with no `refs.<field>` binding: there is no scope to resolve a
# reference in, so the value is refused rather than served raw. The unplanted arm binds the same type
# through `mkInstanceRegistry` and asserts a STDOUT VALUE, the resolved declaration's field, so a
# schema that refused every deferred declaration cannot pass it. Every addressing is bound in the
# prelude: a `}` inside a `${row142/BODY/...}` replacement would end the expansion early.
row142='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  schema = gen.lib.substrate.schema;
  merge = gen.lib.modules.merge;
  kinds = schema.evalSchema {
    modules = [
      {
        config.schema.aglet.options.finish = merge.mkOption { type = merge.types.str; };
        config.schema.lacet.options.tip = merge.mkOption { type = schema.declarationOf "aglet"; };
      }
    ];
  };
  bound = merge.evalModuleTree {
    modules = [
      {
        options.aglets = schema.mkInstanceRegistry kinds.aglet { };
        options.lacets = schema.mkInstanceRegistry kinds.lacet { refs.tip = bound.config.aglets; };
        config.aglets.gilt.finish = "gilded";
        config.lacets.l.tip = "gilt";
      }
    ];
  };
  unbound = (merge.evalModuleTree {
    modules = [
      {
        options.tip = merge.mkOption { type = schema.declarationOf "aglet"; };
        options.spares = merge.mkOption { type = schema.setOf (schema.declarationOf "aglet"); };
        config.tip = "gilt";
        config.spares = [ "gilt" "gilt" ];
      }
    ];
  }).config;
  green = bound.config.lacets.l.tip.finish;
  tipRed = builtins.seq unbound.tip "admitted";
  sparesRed = builtins.deepSeq unbound.spares "admitted";
  caught = if (builtins.tryEval (builtins.deepSeq unbound.spares true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row142 unplanted (a bound deferred declaration resolves to the registry entry)" \
  "${row142/BODY/green}" 0 "" "$tmpdir/row142-green.err" 'gilded'
check "T5 row142 planted   (an unbound declarationOf is refused by name)" \
  "${row142/BODY/tipRed}" 1 \
  "gen-schema: tip: \`declarationOf \"aglet\"' is unbound here. A deferred declaration resolves only through a registry binding" \
  "$tmpdir/row142-tip.err"
check "T5 row142 planted   (an unbound setOf is refused at its first element, in the element's words)" \
  "${row142/BODY/sparesRed}" 1 \
  "\`declarationOf \"aglet\"' is unbound here. A deferred declaration resolves only through a registry binding" \
  "$tmpdir/row142-spares.err"
check "T5 row142 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row142/BODY/caught}" 0 "" "$tmpdir/row142-catch.err" 'CAUGHT'
