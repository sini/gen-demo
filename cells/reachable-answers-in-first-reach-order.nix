# `reachable-answers-in-first-reach-order` — C187, den-hoag-4or0a U0 (ADR-0024). gen-scope's
# `resolve` in mode `reachable` answers in FIRST-REACH order: breadth-first over ⟨node, state⟩, each
# node once, at its first nullable visit, its edges in the order the node declares them. `spool`
# tacks `weft` then `bobbin`, and `weft` tacks `awl`, so `tacks*` from `spool` reaches
# `spool weft bobbin awl`. Mode `witnesses` walks the same graph depth-first, `spool weft awl bobbin`,
# and the codepoint order of the set is `awl bobbin spool weft`: the three differ, so a walk
# answering in either of the other two orders reds here. Declaring `spool`'s edges the other way
# round moves the answer, which is what makes the order a declared one.
{ asserts, genScope }:
let
  walk =
    mode: tacks:
    map (a: a.node)
      (genScope.resolve {
        wf = genScope.wellFormed {
          alphabet = [ "tacks" ];
          expression = "tacks*";
        };
        dataFilter = _: true;
        inherit mode;
      } (scopeOf tacks) "spool").answers;
  scopeOf =
    tacks:
    genScope.eval { parseParent = _: null; }
      {
        children = _: _: { };
        marks = _: _: [ ];
        edges-tacks = _: id: tacks.${id} or [ ];
      }
      (
        genScope.buildRoots {
          parentGraph = genScope.vertices [
            "spool"
            "weft"
            "bobbin"
            "awl"
          ];
        }
      );
  declared = {
    spool = [
      "weft"
      "bobbin"
    ];
    weft = [ "awl" ];
  };
  swapped = declared // {
    spool = [
      "bobbin"
      "weft"
    ];
  };
  reached = walk "reachable" declared;
in
{
  construct = [ "reachable-answers-in-first-reach-order" ];
  check = asserts (
    reached == [
      "spool"
      "weft"
      "bobbin"
      "awl"
    ]
    &&
      walk "witnesses" declared == [
        "spool"
        "weft"
        "awl"
        "bobbin"
      ]
    &&
      builtins.sort builtins.lessThan reached == [
        "awl"
        "bobbin"
        "spool"
        "weft"
      ]
    &&
      walk "reachable" swapped == [
        "spool"
        "bobbin"
        "weft"
        "awl"
      ]
  );
}
