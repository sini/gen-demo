# `addressed-class-crossing` — C74, den-hoag-9vkq. `picot`'s quilting content, adapted, is addressed
# `smocking.picot` and arrives at the smocking terminal beside smocking's own content; the quilting
# terminal (its source) and the tatting terminal (a bystander) receive nothing. Red if the inlet reads
# the extras class-blind (all three receive them, as the node-keyed shape did) or drops a
# class-addressed crossing (none does).
{ asserts, crossingRealized }:
{
  construct = [ "C74" ];
  check = asserts (
    crossingRealized.smocking.picot.extraModules == [ { adaptedFrom.stitch = "quilting"; } ]
    && crossingRealized.smocking.picot.modules == [ { stitch = "smocking"; } ]
    && crossingRealized.quilting.picot.extraModules == [ ]
    && crossingRealized.tatting.picot.extraModules == [ ]
  );
}
