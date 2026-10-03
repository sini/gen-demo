# ── C87 — A FIELD HOLDING A DECLARATION, WRITTEN EITHER WAY (den-hoag-2zjg1) ──
# gen-schema's `declarationOf <kind>` types a field whose value is a declaration: written as a
# reference (the target's identifier) or as the declaration itself (the registry instance), it
# resolves to the instance either way (Néron et al. 2015: a reference resolves to a declaration).
#
# Two NEW kinds in a fresh `evalSchema`, so no stamp pinned elsewhere in this corpus moves: `aglet`
# is the target, and `lacet` references it once through `tip` (`declarationOf "aglet"`) and as a
# set through `spares` (`setOf (declarationOf "aglet")`). `c87Lacets.byName` names its targets by
# identifier, with a duplicate in the set; `c87Lacets.byValue` hands over the declaration values.
#
# `c87Unbound` declares the same two types on plain options that no registry binds, given `"gilt"`
# and `[ "gilt" "gilt" ]` (den-hoag-registry-types-outside-kind-d24lq): with no binding there is no
# scope to resolve them in, so both are refused by name rather than served raw.
{ genMerge, inputs }:
let
  c87Schema = inputs.gen.lib.substrate.schema;
  c87Kinds = c87Schema.evalSchema {
    modules = [
      {
        config.schema.aglet.options.finish = genMerge.mkOption { type = genMerge.types.str; };
        config.schema.lacet.options = {
          tip = genMerge.mkOption { type = c87Schema.declarationOf "aglet"; };
          spares = genMerge.mkOption { type = c87Schema.setOf (c87Schema.declarationOf "aglet"); };
        };
      }
    ];
  };
  c87Eval = genMerge.evalModuleTree {
    modules = [
      {
        options.aglets = c87Schema.mkInstanceRegistry c87Kinds.aglet { };
        options.lacets = c87Schema.mkInstanceRegistry c87Kinds.lacet {
          refs = {
            tip = c87Eval.config.aglets;
            spares = c87Eval.config.aglets;
          };
        };
        config.aglets.gilt.finish = "gilded";
        config.aglets.horn.finish = "polished";
        config.lacets.byName = {
          tip = "gilt";
          spares = [
            "gilt"
            "horn"
            "gilt"
          ];
        };
        config.lacets.byValue = {
          tip = c87Eval.config.aglets.gilt;
          spares = [ c87Eval.config.aglets.horn ];
        };
      }
    ];
  };
  c87Unbound =
    (genMerge.evalModuleTree {
      modules = [
        {
          options.tip = genMerge.mkOption { type = c87Schema.declarationOf "aglet"; };
          options.spares = genMerge.mkOption { type = c87Schema.setOf (c87Schema.declarationOf "aglet"); };
          config.tip = "gilt";
          config.spares = [
            "gilt"
            "gilt"
          ];
        }
      ];
    }).config;
in
{
  inherit c87Unbound;
  c87Aglets = c87Eval.config.aglets;
  c87Lacets = c87Eval.config.lacets;
  c87TipType = c87Schema.declarationOf "aglet";
}
