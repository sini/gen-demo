# `inspect-nests-the-aspect-containment` — C25, den-hoag-o28nu. gen-inspect's renderer options over this
# corpus's own containment: C16's parent graph (child -> parent, `hemline/placket/eyelet` three deep) is
# handed to `fromGraph` as the label `parent`, which is containment in gen-inspect, and drawn with every
# view option: `nest`, `direction`, `shapeOf` and `labelOf`. The picture reads back as the containment —
# each node inside the clusters of its ancestors — and the text of every node is its last path segment
# while its handle still names the whole id.
{
  asserts,
  lib,
  c25Inspect,
  c16Assembled,
  c16Union,
}:
let
  ids = builtins.attrNames c16Assembled.nodes;
  up = id: map (e: e.to) (builtins.filter (e: e.from == id) c16Union.parentGraph.edges);
  facts =
    (c25Inspect.fromGraph { kind = "aspect"; } {
      nodes = ids;
      perLabel.parent = up;
    }).facts;
  segment = id: lib.last (lib.splitString "/" id);
  src = c25Inspect.render.mermaid {
    direction = "TB";
    nest = true;
    shapeOf = _: "round";
    labelOf = n: segment n.id;
  } facts;
  lines = builtins.filter (l: builtins.isString l && l != "") (builtins.split "\n" src);
  # The label's escape, read back (gen-inspect's `mermaidText`, inverted): entities decode and the
  # empty element set before `$` and `:` is dropped. The sigil is built, never written.
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
  # The clusters around each node line, read off the indentation's open/close structure: a
  # `subgraph g<i>["…"]` pushes its title, an `end` pops, a node line records the stack under its text.
  read =
    (builtins.foldl'
      (
        acc: l:
        let
          o = builtins.match " *subgraph g[0-9]+\\[\"([^\"]*)\"]" l;
          n = builtins.match " *n[0-9]+\\(\"([^\"]*)<br/>aspect\"\\)" l;
        in
        if o != null then
          acc // { stack = acc.stack ++ map decode o; }
        else if builtins.match " *end" l != null && acc.stack != [ ] then
          acc // { stack = lib.init acc.stack; }
        else if n != null then
          acc
          // {
            at = acc.at ++ [
              {
                text = decode (builtins.head n);
                around = acc.stack;
              }
            ];
          }
        else
          acc
      )
      {
        stack = [ ];
        at = [ ];
      }
      lines
    ).at;
  # Every ancestor chain the parent graph states, as the segments its clusters are titled with.
  chain =
    id:
    let
      p = up id;
    in
    if p == [ ] then [ ] else chain (builtins.head p) ++ [ (segment (builtins.head p)) ];
  self =
    id: if builtins.any (e: e.to == id) c16Union.parentGraph.edges then [ (segment id) ] else [ ];
  expected = map (id: {
    text = segment id;
    around = chain id ++ self id;
  }) ids;
  bySeg = xs: lib.sort (a: b: builtins.toJSON a < builtins.toJSON b) xs;
in
{
  construct = [ "graph-interrogated" ];
  check = asserts (
    builtins.head lines == "flowchart TB"
    && builtins.length read == builtins.length ids
    && bySeg read == bySeg expected
    && builtins.elem {
      text = "eyelet";
      around = [
        "hemline"
        "placket"
      ];
    } read
  );
}
