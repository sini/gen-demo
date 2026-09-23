# `warm-parity` — T2b. The warm decision byte-identical to a cold one, with both guards (`trace.mode
# == "warm"` and `trace.reused == [ "ferrule" ]`) included. The second is what makes the equality a
# statement about reuse: the base is a plain attrset and `ferrule` is outside the edit, so the warm
# arm splices that leaf from the previous evaluation instead of remerging it. `trace.inert == false`
# is read too: an armed warm run is not inert, which is C33's control.
#
# T2b — the warm decision, byte-identical to the cold one, with BOTH guards
# included. Without `warm.trace.mode == "warm"` both arms could be cold and the
# comparison would measure nothing; without `reused` naming the untouched leaf the
# warm arm could be in warm MODE and still have remerged everything, which is the
# same equality against the same producer and equally measures nothing. `reused`
# is what a defect in the reuse splice moves, so it is what pins the cell to its
# subject.
{
  asserts,
  cold,
  warm,
}:
{
  construct = [ "T2b" ];
  check = asserts (
    builtins.toJSON cold.values == builtins.toJSON warm.values
    && builtins.toJSON cold.provenance == builtins.toJSON warm.provenance
    && (warm.trace.mode or null) == "warm"
    && (warm.trace.reused or [ ]) == [ "ferrule" ]
    # An armed warm run is, by construction, not inert. `or null` so a trace that
    # lost the field reads red rather than defaulting to `false`.
    && (warm.trace.inert or null) == false
    && !(cold ? trace)
  );
}
