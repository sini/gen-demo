# `warm-inert-says-so` — C33, den-hoag-0t9oh. The function-headed T2b base this corpus shipped
# before `c544488`: its warm run is admitted (`trace.mode == "warm"`) and reuses nothing, because
# gen-merge rules every function module dirty. `trace.inert == true` beside `trace.reused == [ ]` is
# what now says so; `mode` alone read "warm" and hid it.
#
# (7b) C33 — a warm run that reuses nothing SAYS SO (den-hoag-0t9oh). The
# function-headed base is admitted (`mode == "warm"`) and remerges every leaf;
# `inert` is the field separating that from warm-parity's armed run above, which
# is this cell's control. `reused == [ ]` is read beside it, so a library that
# set `inert` without the reuse set agreeing could not pass.
{ asserts, fnWarm }:
{
  construct = [ "C33" ];
  check = asserts (
    (fnWarm.trace.mode or null) == "warm"
    && (fnWarm.trace.inert or null) == true
    && (fnWarm.trace.reused or null) == [ ]
  );
}
