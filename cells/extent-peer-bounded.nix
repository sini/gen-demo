# `extent-peer-bounded` — C22, den-hoag-gcr8x. `grommet` carries the `batting` mark, which admits no
# label, so its handed `specialArgs.nodes` is bounded to empty; `bodkin` and `awl` carry no mark and
# are handed the whole class, including themselves (the relation carries self-loops). The withheld
# half is read straight off the adapter — bypassing `realize` — because ADR-0026's one stated
# requirement on a consuming implementation is that a boundary refusal NAME the mark that caused it,
# and `realize`'s own carriage never surfaces a withheld set at all.
#
# extent-peer-bounded — C22, den-hoag-gcr8x. `grommet` carries the `batting`
# mark, which admits no label, so its handed `specialArgs.nodes` is bounded to
# empty; `bodkin` and `awl` carry no mark and are handed the whole class,
# including themselves (the relation carries self-loops). The withheld half is
# read straight off the adapter — bypassing `realize` — because ADR-0026's one
# stated requirement on a consuming implementation is that a boundary refusal
# NAME the mark that caused it, and `realize`'s own carriage never surfaces a
# withheld set at all.
{
  asserts,
  flounceAdapterOf,
  flounceRealized,
}:
{
  construct = [ "C22" ];
  check = asserts (
    flounceRealized.notion.grommet == [ ]
    &&
      flounceRealized.notion.bodkin == [
        "awl"
        "bodkin"
        "grommet"
      ]
    &&
      flounceRealized.notion.awl == [
        "awl"
        "bodkin"
        "grommet"
      ]
    && (flounceAdapterOf "grommet").peerRelation.admitted == [ ]
    &&
      builtins.sort builtins.lessThan (
        map (w: w.target) (flounceAdapterOf "grommet").peerRelation.withheld
      ) == [
        "awl"
        "bodkin"
        "grommet"
      ]
    && builtins.all (w: w.marks == [ "batting" ]) (flounceAdapterOf "grommet").peerRelation.withheld
    && (flounceAdapterOf "bodkin").peerRelation.withheld == [ ]
  );
}
