# `unique-dispatch` — gen-dispatch's `unique` option through the hub: one survivor of the exclusive
# filter is served, and a priority tie under `unique` refuses rather than firing both rules.
{
  asserts,
  selvedgeServed,
  selvedgeTieRefuses,
}:
{
  construct = [ "unique-dispatch" ];
  check = asserts (
    selvedgeServed == [
      {
        __action = "bind";
        by = "bind-the-faille";
      }
    ]
    && selvedgeTieRefuses
  );
}
