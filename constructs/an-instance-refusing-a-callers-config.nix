# ── a gen-schema instance refuses a caller's `config` at its `withArgs` (den-hoag-58bib β) ──
# An instance's own modules read `config` to bind the kind argument and the identity, so gen-schema's
# instance type states `config`, `options` and `prefix` as base module args it refuses from a caller. A
# caller's `config` through the type's `withArgs`, which gen-schema's own `specialArgs` door does not see,
# is refused; `argand` through the same `withArgs` reaches the kind's module, and the instance keeps its
# own fields and identity.
{ genMerge, inputs }:
let
  schema = inputs.gen.lib.substrate.schema;
  spindle =
    (schema.evalSchema { } [
      {
        config.schema.spindle = {
          imports = [
            (
              { argand, ... }:
              {
                options.whorl = genMerge.mkOption {
                  type = genMerge.types.str;
                  default = argand.whorl;
                };
              }
            )
          ];
          options.yarn = genMerge.mkOption { type = genMerge.types.str; };
        };
      }
    ]).spindle;
  at =
    ty:
    (genMerge.evalModuleTree { } [
      {
        options.s = genMerge.mkOption {
          type = ty;
          default = { };
        };
        config.s.yarn = "flax";
      }
    ]).config.s;
  served = at ((schema.mkInstanceType { } spindle).withArgs { argand.whorl = "bead"; });
  planted = at (
    (schema.mkInstanceType { } spindle).withArgs {
      argand.whorl = "bead";
      config = { };
    }
  );
in
{
  instanceRefusalArms = {
    stated = (schema.mkInstanceType { } spindle).refusedArgs;
    plantedRefused = !(builtins.tryEval (builtins.deepSeq planted.whorl null)).success;
    servedWhorl = served.whorl;
    servedYarn = served.yarn;
    servedIdentity = builtins.match "spindle:[0-9a-f]{64}" served.id_hash != null;
  };
}
