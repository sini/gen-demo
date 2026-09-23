# `movement-dedup-function-datum` — C38, den-hoag-eunp3. A NixOS module is a function, and
# `dedups.byDatum` used to address a datum with `toJSON`, which aborts on a lambda where `tryEval`
# cannot hold it. Step 8 now gives every lambda one tag in the bucket address and leaves the
# decision to `==`: `cambricModule`, one binding at `grosgrain` and `faille`, collapses, while a
# fresh `{ config, ... }: { }` literal at `faille` survives. Two kept, one drop, and `noFalseDedup`
# holds.
#
# C38 -- a function-bearing datum under `byDatum` is deduped by the declared
# relation instead of aborting where `tryEval` cannot hold it. The shared module
# collapses (Nix `==` is true of one binding), the fresh literal survives, and the
# one drop recorded is licensed.
{
  asserts,
  collisionModules,
  noFalseDedup,
}:
{
  construct = [ "C38" ];
  check = asserts (
    builtins.length collisionModules.contributions == 2
    && builtins.length collisionModules.dropped == 1
    && noFalseDedup collisionModules
  );
}
