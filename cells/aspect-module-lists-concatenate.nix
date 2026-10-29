# `aspect-module-lists-concatenate` — C97, den-hoag-a0gc arm (e). Two modules declare the aspect
# container over `aspect-cnf.nix`, one adding `baize` to every aspect through `aspectModules` and
# `boucle` to every aspect's `meta` through `metaModules`, the other adding `chenille`. The module
# lists are payload, not identity, so gen-aspects concatenates them as nixpkgs concatenates a
# submodule's `modules`: `stitch` reads all three in either declaration order. Alone, the second
# declaration's aspect has no `baize`, so the union is what supplies it. A declaration differing
# at an inert key (`closedKeys`) is still refused, catchably. The differing declaration flips
# whatever `aspect-cnf.nix` states, so it differs under both states of the corpus's own cnf; the
# `or false` restates gen-aspects' default for `closedKeys` at this consumer. If that default ever
# flips to `true` and the corpus drops its own `closedKeys = true`, this cell reds, loudly. A later
# declaration states the container's TYPE only: two both stating its `default` are refused, as
# nixpkgs refuses them (`bothHave`; the last row).
{
  asserts,
  genAspects,
  genMerge,
}:
let
  cnf = import ../aspect-cnf.nix;
  str =
    v:
    genMerge.mkOption {
      type = genMerge.types.str;
      default = v;
    };
  first = cnf // {
    aspectModules = [ { options.baize = str "felted"; } ];
    metaModules = [ { options.boucle = str "looped"; } ];
  };
  second = cnf // {
    aspectModules = [ { options.chenille = str "piled"; } ];
  };
  optionOf = c: (genAspects.mkAspectSchema c).mkAspectOption { };
  # the first declaration as written, every later one its type alone
  stitchWith =
    later: cnfs:
    (genMerge.evalModuleTree { } (
      [ { options.aspects = optionOf (builtins.head cnfs); } ]
      ++ map (c: { options.aspects = later (optionOf c); }) (builtins.tail cnfs)
      ++ [
        { aspects.stitch = { }; }
      ]
    )).config.aspects.stitch;
  stitch = stitchWith (o: genMerge.mkOption { inherit (o) type; });
  read = s: {
    baize = s.baize or null;
    chenille = s.chenille or null;
    boucle = s.meta.boucle or null;
  };
  both = {
    baize = "felted";
    chenille = "piled";
    boucle = "looped";
  };
in
{
  construct = [ "aspect-containers-module-lists-unioned" ];
  check = asserts (
    read (stitch [
      first
      second
    ]) == both
    &&
      read (stitch [
        second
        first
      ]) == both
    && (read (stitch [ second ])).baize == null
    && !(builtins.tryEval (
      builtins.deepSeq (read (stitch [
        first
        (second // { closedKeys = !(cnf.closedKeys or false); })
      ])) null
    )).success
    && !(builtins.tryEval (
      builtins.deepSeq (read (
        stitchWith (o: o) [
          first
          second
        ]
      )) null
    )).success
  );
}
