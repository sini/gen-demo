{
  title = "a spawn keeps the order its builder wrote";
  adr = "0012, 0016 ruling 7";
  what = "`spawn-keeps-production-order`: a `selvage` host's `spawns.picot` returns `[ picot:tatting@lace picot:ruche@lace ]` as a list of `{ name; value; }`, and `childrenIds` and `allNodeIds` answer in that order, where the list aborted `expected a set but found a list` uncatchably; the same builder through `listToAttrs` reads the names' order, `ruche` first";
}
