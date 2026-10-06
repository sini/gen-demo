{
  title = "distinct nodes stay distinct in the trace";
  adr = "0025 item 1, 0024";
  what = "`trace-distinct-nodes`: a derivation where a scope name belongs is refused by name at `hashTrace` and at `edgeSortKey`, where the sort key answered the store path's key; `renderEntry` discloses it as `‹set›` and prints the store path's string as itself; two entries differing only in distance share one key and separate in the fingerprint; the store path's string and the genuine trace are the control";
}
