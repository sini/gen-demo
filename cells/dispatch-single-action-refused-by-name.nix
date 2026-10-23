# `dispatch-single-action-refused-by-name` — gen-dispatch's `produce` contract through the hub: a
# policy returning one action refuses by name when the group's actions are read, and the same policy
# returning a list is served.
{
  asserts,
  weftListServed,
  weftSingleRefuses,
}:
{
  construct = [ "dispatch-single-action-refused-by-name" ];
  check = asserts (
    weftListServed == {
      weft = [
        {
          __action = "thread";
          by = "list";
        }
      ];
    }
    && weftSingleRefuses
  );
}
