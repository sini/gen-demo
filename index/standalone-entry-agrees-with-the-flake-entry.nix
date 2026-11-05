{
  title = "the standalone entry agrees with the flake entry";
  adr = "0031";
  what = "`import inputs.gen.outPath { }` builds the roster from the hub's own lock, one value per lock node, and answers the identity mint's question as `inputs.gen.lib` does, over the same roster keys";
}
