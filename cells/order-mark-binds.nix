# `order-mark-binds` — C28, ADR-0026 / M9. The effective visibility order is the LEXICOGRAPHIC
# PRODUCT of a declared order mark with the declaration's own order, MARK OUTER, so a declaration
# may refine only inside the mark's ties and can neither erase nor reverse a pair the mark states.
# The fixture is the corpus's own graph — `pewter` reaches `grosgrain` on the real `tacks` edge and
# `damask` on the real `gathers` edge, read through C2's own `byLabel` accessor, with each scope's
# datum taken from the value that node really declares — and the declaration's order is written to
# DECLINE: `gathers` outranks `tacks`, and `$ = -1` puts the root's own empty path below both
# arrivals. Two arms, the same call, varying the mark alone: under the binding mark (`tacks` ≻ `$` ≻
# `gathers`) `grosgrain`'s real `gauge` wins and BOTH the root's own path and the query-preferred
# arrival are shadowed; under the identity mark the product degenerates and `pewter` keeps its real
# `spool`. The second arm is what makes the first a statement about the mark rather than about a
# library that happened to prefer `tacks`. Resolved values on both arms, never the presence of the
# field: `orderMark` is required and total, so a cell that only observed it reaching the call would
# be green on a build that dropped it from the product entirely. The optional step in
# `(tacks|gathers)?` is load-bearing — dropping the `?` un-admits the root's own empty path and
# there is no decline left to overcome.
#
# C28 — the order mark BINDS a declaration written to decline it. Both arms
# are the SAME call over the corpus's own graph, varying the mark alone, and both
# read RESOLVED VALUES rather than the presence of the field: under the binding
# mark `grosgrain`'s real `gauge` wins and the root's own path is shadowed; under
# the identity mark the lexicographic product degenerates, the declaration's own
# order decides alone, and `pewter` keeps its real `spool`. The second arm is the
# control that makes the first a statement about the mark — without it the cell
# would pass on a library that ignored the mark and simply preferred `tacks`.
{
  asserts,
  genValues,
  mandateBound,
  mandateDeclined,
}:
{
  construct = [ "C28" ];
  check = asserts (
    mandateBound.value == [ "fine" ]
    && mandateDeclined.value == [ "linen" ]
    && map (c: c.scope) mandateBound.contributions == [ "grosgrain" ]
    && map (c: c.scope) mandateDeclined.contributions == [ "pewter" ]
    &&
      map (c: c.scope) mandateBound.shadowed == [
        "pewter"
        "damask"
      ]
    # The two literals above ARE the corpus's own declared content, named here so
    # the cell cannot quietly decouple from the registries it claims to read.
    && genValues.bobbins.grosgrain.gauge == "fine"
    && genValues.thimbles.pewter.spool == "linen"
  );
}
