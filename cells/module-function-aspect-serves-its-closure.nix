# `module-function-aspect-serves-its-closure` — C197, den-hoag-lwbb1. gen-rules' registration table is
# mounted inside gen-aspects' aspect submodule, so a closure in the result of a module function written
# at an aspect position registers when gen-merge applies the function, and is served like the same text
# written outside it: `hem`'s closure fires `"hem-pewter"` at `thimble = "pewter"`, and `seam`'s class
# closure keeps its `has bobbin` guard, so under the declared set it does not fire at a context without
# `bobbin`. `seamCoordinateOnly`'s class closure over `bobbin` alone keeps the same guard and is delivered
# `"seam-spool"` at a context with `bobbin` (den-hoag-d13lv). Control: `hemControl`, `seamControl` and
# `seamCoordinateOnlyControl`, the same text outside the function. Before, `hem`'s closure was refused by
# gen-aspects' bare-closure refusal, `seam`'s was delivered with its guard dropped, and
# `seamCoordinateOnly`'s firing was refused by the door at its control too.

{
  asserts,
  c197Registrations,
  c197Hem,
  c197HemControl,
  c197Seam,
  c197SeamControl,
  c197SeamCoordinateOnly,
  c197SeamCoordinateOnlyControl,
  c197HasBobbin,
}:

{
  construct = [ "C197" ];
  check = asserts (
    c197Registrations == 6
    && c197Hem.atPewter == { description = "hem-pewter"; }
    && c197Hem == c197HemControl
    && c197Seam.condition == c197HasBobbin
    && c197Seam.atPewter == null
    && c197Seam == c197SeamControl
    && c197SeamCoordinateOnly.atSpool == "seam-spool"
    && c197SeamCoordinateOnly.condition == c197HasBobbin
    && c197SeamCoordinateOnly == c197SeamCoordinateOnlyControl
  );
}
