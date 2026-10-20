# `prelude-parity-over-the-corpus-graph` — den-hoag-pl8cq. gen-prelude's nixpkgs-parity primitives,
# reached through the hub's `substrate.prelude` bucket, project the walked node set (`tacked`, the
# `tacks*` then `piping*` query over the evaluated scope) and the composed node records. Red if any
# of the seven names is missing from the hub's prelude or departs from nixpkgs lib's answer.
{
  asserts,
  config,
  inputs,
  tacked,
}:
let
  prelude = inputs.gen.lib.substrate.prelude;
  nodes = config.gen.composed.nodes;
  # A deep update of one node's record: the other nodes and that node's own keys survive.
  threaded = prelude.recursiveUpdate nodes { pewter.thread = "silk"; };
in
{
  construct = [ "prelude-parity-over-the-corpus-graph" ];
  check = asserts (
    prelude.reverseList tacked == [
      "pewter"
      "grosgrain"
      "faille"
      "damask"
    ]
    &&
      prelude.remove "faille" tacked == [
        "damask"
        "grosgrain"
        "pewter"
      ]
    && builtins.filter (prelude.hasSuffix "er") tacked == [ "pewter" ]
    &&
      map (prelude.removeSuffix "ain") tacked == [
        "damask"
        "faille"
        "grosgr"
        "pewter"
      ]
    && prelude.splitString "," (prelude.concatMapStringsSep "," (n: n) tacked) == tacked
    && prelude.concatMapStrings (n: builtins.substring 0 1 n) tacked == "dfgp"
    && builtins.attrNames threaded == builtins.attrNames nodes
    && threaded.pewter.thread == "silk"
    &&
      builtins.attrNames threaded.pewter
      == builtins.sort builtins.lessThan (builtins.attrNames nodes.pewter ++ [ "thread" ])
  );
}
