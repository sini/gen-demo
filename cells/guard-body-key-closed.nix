# `guard-body-key-closed` — C111 over a guard body. The corpus's closed aspect-body vocabulary
# (`aspect-cnf.nix`) judges a guard body's keys as it judges a static body's: a guard `gore` whose body
# misspells `nixos` as `nixso` is refused catchably where it is declared and where it fires, and the
# spelt guard's fired entry carries its class. The static twin is `aspect-body-key-closed`.
{
  asserts,
  genAspects,
  genMerge,
  inputs,
}:
let
  cnf = import ../aspect-cnf.nix;
  gore =
    body:
    (genMerge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      { aspects.gore = genAspects.guard (genAspects.pred.has "loom") body; }
    ]).config.aspects.gore;
  fire =
    g:
    (genAspects.instanceOf cnf { } {
      aspect = "gore";
      context.loom = "l1";
      sources.loom = inputs.gen.lib.substrate.identity.hashIdentity "entity" [ "name" ] (_: "l1");
    } g).entry;
  caught = v: (builtins.tryEval (builtins.deepSeq v v)).success;
  misspelt = gore { nixso.boot.loader.grub.enable = false; };
  spelt = gore { nixos.boot.loader.grub.enable = false; };
in
{
  construct = [ "aspect-bodys-first-level-is-a-closed-vocabulary" ];
  check = asserts (
    !(caught misspelt)
    && !(caught (fire misspelt))
    &&
      builtins.filter (k: genAspects.keyCategory cnf k == "class") (builtins.attrNames (fire spelt)) == [
        "nixos"
      ]
  );
}
