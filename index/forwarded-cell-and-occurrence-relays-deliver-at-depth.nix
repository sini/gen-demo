{
  title = "forwarded cell and occurrence relays deliver at depth";
  adr = "0025, 0032";
  what = "`forwarded-cell-and-occurrence-relays-deliver-at-depth`: gen-delivery's `forward` reads a W1 chain, a twin ladder and an occurrence relay 4096 hops deep to a value (4097, 4097 and 2 spools at the deepest target), where each read used to abort with `max-call-depth exceeded`; the row `a-forward-relay-refusal-at-depth-is-refused-by-name` reads a refusing relay's text at the same depth";
}
