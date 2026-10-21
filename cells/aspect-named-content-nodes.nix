# `named-inline-content-is-one-node` — aspect-named-content-nodes, den-hoag-qxip5. `bias`, included by
# `hem` and by `facing`, is one node both sites name, and `frock`, reaching both, receives it once;
# the factory `tape` gives two classes at one `name` position, each its own content; `bias-inl` is one
# node under `bias`. Ids are asserted by their structure (the `name` position is a store path, which
# moves with the corpus source). Red where named content is no node: `includesOf` drops it, and
# `frock` receives `bias` twice.
{
  asserts,
  namedNodesFacts,
  namedNodesIds,
  namedNodesStitches,
}:
let
  f = namedNodesFacts;
  isClass = n: builtins.match "@/includes/(bias|tape)@.*" n != null;
  # Total over the red arm (no class node): every read below answers rather than aborts.
  at = l: i: if builtins.length l > i then builtins.elemAt l i else "<none>";
  biases = builtins.filter (n: builtins.match "@/includes/bias@[^/]*" n != null) f.nodes;
  biasId = at biases 0;
  tapes = builtins.filter (n: builtins.match "@/includes/tape@.*" n != null) f.nodes;
in
{
  construct = [ "named-inline-content-is-one-node" ];
  check = asserts (
    builtins.length biases == 1
    && at f.includesOf.hem 0 == biasId
    && at f.includesOf.facing 0 == biasId
    && builtins.all isClass (f.includesOf.hem ++ f.includesOf.facing)
    && f.unresolvedIncludesOf.hem == [ ]
    && f.unresolvedIncludesOf.facing == [ ]
    && builtins.length tapes == 2
    && at f.includesOf.hem 1 != at f.includesOf.facing 1
    && (f.parentOf.${biasId} or "<none>") == null
    && (f.includesOf.${biasId} or null) == [ "${biasId}/includes/0" ]
    && (f.parentOf."${biasId}/includes/0" or null) == biasId
    &&
      namedNodesStitches == {
        frock = [
          "hem"
          "facing"
          "bias"
          "satin"
          "twill"
          "bias-inl"
        ];
        smock = [
          "facing"
          "bias"
          "twill"
          "bias-inl"
        ];
      }
    && builtins.length (namedNodesIds "frock") == 6
    && builtins.elem biasId (namedNodesIds "frock")
  );
}
