# ── A KIND WITH A PARENT, ITS COLLECTION LEFT IN THE IDENTITY, HOLDS A VALUE THAT READS AN INSTANCE ──
# (den-hoag-9zyp7 OQ2; den#719's shape, undeclared, on a kind that composes a parent.) A `berth` kind
# inherits `dock`, and its `waivers` collection holds a note whose value reads the instance `kelp`. A kind
# that composes a parent is a keyed module: its graph node is its declaration node, read before
# composition, and its mark key is read only where another occurrence of its name meets it; so importing
# the kind into `kelp` reads no identity, and the instance, the kind's mark, the instance's `id_hash` and
# the collection are all values.
{ genMerge, inputs }:
let
  kpiSchema = inputs.gen.lib.substrate.schema;
  kpiTree =
    (genMerge.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = kpiSchema.mkSchemaOption {
            collections.waivers = {
              default = [ ];
              merge = acc: val: acc ++ val;
            };
          };
          options.berths = kpiSchema.mkInstanceRegistry { } config.schema.berth;
          options.notes = genMerge.mkOption { type = genMerge.types.attrsOf genMerge.types.anything; };
          config.schema.dock.options.pier = genMerge.mkOption {
            type = genMerge.types.int;
            default = 4;
          };
          config.schema.berth = {
            inherits = [ config.schema.dock ];
            options.mooring = genMerge.mkOption { type = genMerge.types.str; };
            waivers = [ config.notes.ballast ];
          };
          config.berths.kelp.mooring = "pier-4";
          config.notes.ballast.at = config.berths.kelp.mooring;
        }
      )
    ]).config;
in
{
  kpiRead = {
    mooring = kpiTree.berths.kelp.mooring;
    pier = kpiTree.berths.kelp.pier;
    marked = builtins.isString kpiTree.schema.berth.__mint.minted;
    keyed = builtins.isString kpiTree.berths.kelp.id_hash;
    waived = map (n: n.at) kpiTree.schema.berth.waivers;
  };
}
