# `mkoptiontype-samename-redeclaration` — C79, den-hoag-bfc0k. Two check-only
# `mkOptionType "tension"` declarations for one option merge only when they are one construction.
# Before, the later declaration won with its own check: `tension<10` then `tension>100` refused 5 and
# accepted 500, and swapping the files swapped the answer. Both orders are now refused catchably, and
# so is a pair whose `description` carries a back-edge — the shape a bare record `==` cannot decide
# without aborting. One value declared in two files reads its value and keeps its check, and a `//`
# derivation of it is another value and is refused beside it.
{ asserts, genMerge }:
let
  t = genMerge.types;
  lt10 = v: builtins.isInt v && v < 10;
  gt100 = v: builtins.isInt v && v > 100;
  tension =
    check:
    t.mkOptionType {
      name = "tension";
      inherit check;
    };
  slack = tension lt10;
  taut = tension gt100;
  knot =
    _:
    let
      r = {
        loop = r;
      };
    in
    t.mkOptionType {
      name = "tension";
      description = r;
      check = lt10;
    };
  read =
    types: v:
    (genMerge.evalModuleTree {
      modules =
        builtins.genList (i: {
          _file = "/demo/beam${toString i}.nix";
          options.tension = genMerge.mkOption { type = builtins.elemAt types i; };
        }) (builtins.length types)
        ++ [ { tension = v; } ];
    }).config.tension;
  decides = e: (builtins.tryEval (builtins.deepSeq e true)).success;
in
{
  construct = [ "C79" ];
  check = asserts (
    # two constructions: refused catchably, both orders, and with a back-edge under `description`
    !(decides (read [ slack taut ] 500))
    && !(decides (read [ taut slack ] 5))
    && !(decides (read [ (knot 1) (knot 2) ] 5))
    # one construction: reads its value and keeps its check
    && read [ slack slack ] 5 == 5
    && !(decides (read [ slack slack ] 500))
    && (
      let
        k = knot 1;
      in
      read [ k k ] 5 == 5
    )
    # a `//` derivation is another value
    && !(decides (
      read [
        slack
        (slack // { description = "frayed"; })
      ] 5
    ))
  );
}
