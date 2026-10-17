# ── A KIND WHOSE PARENT KEEPS A COLLECTION IN ITS IDENTITY, HOLDING A VALUE THAT READS AN INSTANCE ──
# (den-hoag-c2836; den#719's shape, undeclared, one level up.) `dock` keeps its `waivers` collection in
# its identity and holds a note whose value reads `kelp`, an instance of `berth`, which inherits `dock`.
# The berth composes the dock by the construction it is, its stamp slot and its content cells, and reads
# no mark to do it; so the instance, the dock's and the berth's marks, the instance's `id_hash` and the
# collection are all values. A read that answers an identity still holds the dock's whole stamp, so a
# `//` copy over the dock's mark, inherited by value, is refused where the berth's mark is read.
{ genMerge, inputs }:
let
  kphSchema = inputs.gen.lib.substrate.schema;
  kphTreeWith =
    parentOf:
    (genMerge.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = kphSchema.mkSchemaOption {
            collections.waivers = {
              default = [ ];
              merge = acc: val: acc ++ val;
            };
          };
          options.berths = kphSchema.mkInstanceRegistry { } config.schema.berth;
          options.notes = genMerge.mkOption { type = genMerge.types.attrsOf genMerge.types.anything; };
          config.schema.dock = {
            options.pier = genMerge.mkOption {
              type = genMerge.types.int;
              default = 4;
            };
            waivers = [ config.notes.ballast ];
          };
          config.schema.berth = {
            inherits = [ (parentOf config.schema.dock) ];
            options.mooring = genMerge.mkOption { type = genMerge.types.str; };
          };
          config.berths.kelp.mooring = "pier-4";
          config.notes.ballast.at = config.berths.kelp.mooring;
        }
      )
    ]).config;
  kphTree = kphTreeWith (d: d);
  # the copy: the dock with its mark replaced, inherited by value
  kphCopy = kphTreeWith (d: d // { __mint.minted = "forged"; });
in
{
  kphRead = {
    mooring = kphTree.berths.kelp.mooring;
    pier = kphTree.berths.kelp.pier;
    docked = builtins.isString kphTree.schema.dock.__mint.minted;
    marked = builtins.isString kphTree.schema.berth.__mint.minted;
    keyed = builtins.isString kphTree.berths.kelp.id_hash;
    waived = map (n: n.at) kphTree.schema.dock.waivers;
  };
  kphCopyMarked = builtins.tryEval kphCopy.schema.berth.__mint.minted;
}
