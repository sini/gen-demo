# `kind-ancestors-in-order` (den-hoag-w523e): a chain and a diamond declared in one tree, the
# subjects of gen-schema's `ancestorsForKind`.
{ genMerge, genSchema }:
let
  intOpt = genMerge.mkOption { type = genMerge.types.int; };
in
{
  orderedAncestorKinds =
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { }; }
      {
        config.schema =
          builtins.mapAttrs
            (n: ps: {
              inherits = ps;
              options.${n} = intOpt;
            })
            {
              seam = [ ];
              hem = [ "seam" ];
              selvage = [ "hem" ];
              fold = [ ];
              pleat = [ "fold" ];
              tuck = [ "fold" ];
              gusset = [
                "pleat"
                "tuck"
              ];
            };
      }
    ]).config.schema;
}
