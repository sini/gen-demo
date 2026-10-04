# `mint-sites-collapsed-diamond` — C189, den-hoag-u528o. Two emitters of one identifier that agree
# collapse to ONE node, and the result's `sites` names BOTH producers in the merge's order; an
# identifier emitted once names its one. The node record stays the closed `{ content; identity; kind; }`
# (the sites ride beside it, not on it). Turns red if `mintStrata` stops publishing `sites`, drops the
# second agreeing producer (the accumulator it replaced wrote a key's site only on the first branch
# that saw it), or folds the producers into the node record.
{ asserts, c189Minted }:
{
  construct = [ "C189" ];
  check = asserts (
    builtins.attrNames c189Minted.nodes == [
      "eyelet"
      "rivet"
    ]
    &&
      c189Minted.sites == {
        eyelet = [
          "c:eyelet-a"
          "c:eyelet-b"
        ];
        rivet = [ "c:rivet" ];
      }
    &&
      builtins.attrNames c189Minted.nodes.eyelet == [
        "content"
        "identity"
        "kind"
      ]
  );
}
