{
  title = "a nested tree typed bare reads its own config";
  adr = "0025 item 1, 0008 item 2";
  what = "`bare-tree-reads-its-own-config`: a `check = true` tree whose leaf `sub` is another tree defined `mkIf config.bolt.flag …` reads `sub.k = \"s\"`, where it aborted with infinite recursion; `sub.bogus` is refused read deep and a value at a sibling read, and `.undeclared` names it; a strict warm evaluation over a lax prior goes cold and says why";
}
