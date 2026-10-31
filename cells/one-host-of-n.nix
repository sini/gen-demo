# `delivery-one-host` — one-host-of-n, den-hoag-ien5k. `spindle7`'s toplevel in a 16-spindle fleet is
# the same derivation as `spindle7` realized alone, so the fleet's other nodes contribute nothing to
# one host's read. Red if a peer's projection leaks into a host's value (the drvPaths part). EXERCISE,
# not an oracle for the change it accompanies: the corpus counts no thunks, and the cell is green on
# the unshared reach too; gen-delivery's process plane gates the cost.
{ asserts, inputs }:
let
  fleet = import ../fixtures/one-host-of-n { inherit inputs; };
  drvOf =
    configurations:
    builtins.unsafeDiscardStringContext configurations.spindle7.config.system.build.toplevel.drvPath;
in
{
  construct = [ "delivery-one-host" ];
  check = asserts (
    drvOf (fleet {
      names = builtins.genList (k: "spindle${toString k}") 16;
    }) == drvOf (fleet {
      names = [ "spindle7" ];
    })
  );
}
