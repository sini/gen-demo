# `forwarded-cell-and-occurrence-relays-deliver-at-depth` — gen-delivery's `forward` reads a relay 4096 hops deep
# to a value: the W1 chain's and the twin ladder's deepest target each hold all 4097 spools, and the occurrence
# relay's holds two, `t0`'s and its own. Red at gen-demo main's pins, where each read aborts with
# `max-call-depth exceeded`, which `tryEval` cannot catch. The refusal half, a relay whose foot refuses and whose
# read reaches that refusal BY NAME at the same depth, is the row
# `ci/refusals/a-forward-relay-refusal-at-depth-is-refused-by-name.sh`.
{ asserts, relaysAtDepth }:
let
  inherit (relaysAtDepth)
    d
    chain
    ladder
    occurrence
    ;
in
{
  construct = [ "forwarded-cell-and-occurrence-relays-deliver-at-depth" ];
  check = asserts (
    builtins.length (builtins.attrNames chain) == d + 1
    && chain.t0.thread == "t0"
    && chain."t${toString d}".thread == "t${toString d}"
    && builtins.length (builtins.attrNames ladder) == d + 1
    &&
      builtins.attrNames occurrence == [
        "t0"
        "t${toString d}"
      ]
  );
}
