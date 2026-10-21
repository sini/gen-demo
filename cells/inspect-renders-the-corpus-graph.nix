# `inspect-renders-the-corpus-graph` — C25, den-hoag-0w06f. The picture of this corpus's graph reads back
# as that graph: every node line binds its own handle, so no two nodes merge, and the label each
# carries decodes to its id. The seam head `seam:<thimble>:<bobbin>` is the corpus's own id with `:` in
# it, which is what a handle that spells the id has to get right.
{
  asserts,
  lib,
  c25PolicyIr,
  seamHead,
}:
let
  facts = c25PolicyIr.facts;
  # The label's escape, read back: entities decode, and the empty element set before `$` and `:`
  # (and inside `\n`) is dropped. The sigil is built, never written.
  sigil = builtins.fromJSON "\"\\u0023\"";
  decode =
    builtins.replaceStrings
      [
        "${sigil}35;"
        "${sigil}quot;"
        "${sigil}lt;"
        "${sigil}gt;"
        "${sigil}amp;"
        "${sigil}96;"
        "${sigil}37;"
        "<b></b>"
      ]
      [
        sigil
        "\""
        "<"
        ">"
        "&"
        "`"
        "%"
        ""
      ];
  nodeLines = builtins.filter (m: m != null) (
    map (builtins.match "  ([^ ]+)\\[\"([^\"]*)\"]") (
      builtins.filter builtins.isString (builtins.split "\n" (c25PolicyIr.render.mermaid { } facts))
    )
  );
  idOf = label: decode (builtins.head (builtins.split "<br/>" label));
  ids = map (n: n.id) facts.nodes;
in
{
  construct = [ "graph-interrogated" ];
  check = asserts (
    builtins.length (lib.unique (map builtins.head nodeLines)) == builtins.length ids
    &&
      lib.sort builtins.lessThan (map (m: idOf (builtins.elemAt m 1)) nodeLines)
      == lib.sort builtins.lessThan ids
    && builtins.elem seamHead ids
  );
}
