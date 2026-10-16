# ── A KIND'S COLLECTION, LEFT IN THE IDENTITY, HOLDS A VALUE THAT READS AN INSTANCE OF THE KIND ──
# (den-hoag-9zyp7; den#719's shape, undeclared.) A `berth` kind's `waivers` collection holds a note whose
# value reads the instance `kelp`, and the schema does NOT declare `waivers` `identity = false`, so its
# contents stay in the kind's mark. Importing the kind into `kelp` reads only the cells the import
# consumes, never the identity, so the instance and the identity are both values. A `//` copy that
# replaces only the kind's sealed subjects is refused by name where an identity is read.
{ genMerge, inputs }:
let
  kciSchema = inputs.gen.lib.substrate.schema;
  kciTree =
    (genMerge.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = kciSchema.mkSchemaOption {
            collections.waivers = {
              default = [ ];
              merge = acc: val: acc ++ val;
            };
          };
          options.berths = kciSchema.mkInstanceRegistry { } config.schema.berth;
          options.notes = genMerge.mkOption { type = genMerge.types.attrsOf genMerge.types.anything; };
          config.schema.berth = {
            options.mooring = genMerge.mkOption { type = genMerge.types.str; };
            waivers = [ config.notes.ballast ];
          };
          config.berths.kelp.mooring = "pier-4";
          config.notes.ballast.at = config.berths.kelp.mooring;
        }
      )
    ]).config;
  # the copy: a schema whose kind carries a sealed subject (`computed`), its `__sealed` replaced
  kciCopy =
    (genMerge.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = kciSchema.mkSchemaOption { computed = _: _: { pier = 4; }; };
          options.berths = kciSchema.mkInstanceRegistry { } (config.schema.berth // { __sealed = { }; });
          config.schema.berth.options.mooring = genMerge.mkOption { type = genMerge.types.str; };
          config.berths.kelp.mooring = "pier-4";
        }
      )
    ]).config;
in
{
  kciRead = {
    mooring = kciTree.berths.kelp.mooring;
    marked = builtins.isString kciTree.schema.berth.__mint.minted;
    keyed = builtins.isString kciTree.berths.kelp.id_hash;
    waived = map (n: n.at) kciTree.schema.berth.waivers;
  };
  kciCopyKeyed = builtins.tryEval kciCopy.berths.kelp.id_hash;
}
