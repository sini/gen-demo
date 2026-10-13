# ── A KIND'S COLLECTION, DECLARED `identity = false`, HOLDS A VALUE THAT READS AN INSTANCE OF THE KIND ──
# (den-hoag-ux9xg; den#719's shape.) A `berth` kind's `waivers` collection holds a note whose value
# reads the instance `kelp`. The schema declares `waivers` `identity = false`, so its contents enter
# no mark, no sealed subject and no module key, and importing the kind into `kelp` reads none of it.
# Three arms, one per read that took the contents through the mark at the hub before: the import's
# completion stamp (`plain`), the module key of a kind with a parent (`inheriting`), and a parent
# whose own collection reaches the instance, named by value (`parentHolds`).
{ genMerge, inputs }:
let
  kcoiSchema = inputs.gen.lib.substrate.schema;
  kcoiWith =
    shape:
    (genMerge.evalModuleTree { } [
      (
        { config, ... }:
        {
          options.schema = kcoiSchema.mkSchemaOption {
            collections.waivers = {
              default = [ ];
              merge = acc: val: acc ++ val;
              identity = false;
            };
          };
          options.berths = kcoiSchema.mkInstanceRegistry { } config.schema.berth;
          options.notes = genMerge.mkOption { type = genMerge.types.attrsOf genMerge.types.anything; };
          config.schema.quay =
            if shape == "parentHolds" then { waivers = [ config.notes.ballast ]; } else { };
          config.schema.berth =
            (if shape == "plain" then { } else { inherits = [ config.schema.quay ]; })
            // {
              options.mooring = genMerge.mkOption { type = genMerge.types.str; };
            }
            // (if shape == "parentHolds" then { } else { waivers = [ config.notes.ballast ]; });
          config.berths.kelp.mooring = "pier-4";
          config.notes.ballast.at = config.berths.kelp.mooring;
        }
      )
    ]).config;
  kcoiRead =
    shape:
    let
      c = kcoiWith shape;
    in
    {
      mooring = c.berths.kelp.mooring;
      marked = builtins.isString c.schema.berth.__mint.minted;
      waived = map (n: n.at) (
        if shape == "parentHolds" then c.schema.quay.waivers else c.schema.berth.waivers
      );
    };
in
{
  kcoiPlain = kcoiRead "plain";
  kcoiInheriting = kcoiRead "inheriting";
  kcoiParentHolds = kcoiRead "parentHolds";
}
