{
  title = "an aspect's declared surface, both planes";
  adr = "0012";
  what = "`aspect-declared-surface`: the aspect container over `aspect-cnf.nix` declares `includes`, `nixos`, `welt` and `gusset`, each a key the composed `stitch` carries; a `schema.aspect.options.priority` declaration puts `priority` in the value (`50`) and in the declared option set, and neither without it. Before, the declared set read `[ ]` in both arms";
}
