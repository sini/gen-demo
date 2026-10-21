# `typed-sited-fold` — den-hoag-bluqd. A kind's resource fold is handed its contributor edges
# `[ { site; value; } ]`, so a typed fold refuses an ill-typed fragment naming the claim it came
# from. The kind declares `foldFragments = folds.typed int folds.same` over gen-types' `int`
# (reached through the hub, `inputs.gen.lib.modules.types`), and two claims in one dedup group are
# read through `resolveClaims`:
#   1. an agreeing well-typed pair resolves to its value;
#   2. an agreeing ILL-typed pair (`"22"`, `"22"`) refuses, catchably;
#   3. LIVE CONTROL, same run: that same pair through the untyped `folds.same` resolves. The pair is
#      two EQUAL values so the control isolates the checker: a mixed pair (`22`, `"22"`) is refused by
#      `same`'s comparison too, and the control would read red against a correct build.
{
  asserts,
  genScope,
  inputs,
}:
let
  inherit (genScope) folds;
  int = inputs.gen.lib.modules.types.int;
  portOf =
    fold: ports:
    (genScope.resolveClaims { }
      (genScope.mkKinds [
        (genScope.mkKind {
          dedupKey = _: "one-group";
          foldFragments = fold;
          resolve = c: _: { resources.port = c.port; };
        } "endpoint")
      ])
      (
        builtins.genList (
          i:
          genScope.mkClaim {
            kind = "endpoint";
            subject = {
              id_hash = "selvage-${toString i}";
              name = "selvage-${toString i}";
            };
            port = builtins.elemAt ports i;
          }
        ) (builtins.length ports)
      )
    ).resources.endpoint.port;
  typedSame = folds.typed int folds.same;
  refuses = e: !(builtins.tryEval (builtins.deepSeq e null)).success;
in
{
  construct = [ "kind-fold-refuses-naming-its-contributor" ];
  check = asserts (
    portOf typedSame [
      22
      22
    ] == 22
    && refuses (
      portOf typedSame [
        "22"
        "22"
      ]
    )
    &&
      portOf folds.same [
        "22"
        "22"
      ] == "22"
  );
}
