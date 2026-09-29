# `withheld-negative-support` — C96, den-hoag-ea3j4. At pass 1 (`complete = false`) the shirr atom
# is derived through `not smocked:damask`, and it reads `P` with `included` refusing (`tryEval`
# fails) and `verdict` refusing too. Pass 2, handed pass 1's record as `prior`, adds
# `smocked:damask` and answers it `T`, out; a pass 2 that drops pass 1's declarations is refused.
# The control is the negation-free `furl:damask` on the same pass-1 record, served `P`, in. Reds on
# a gen-program that serves a derived atom `included = true` under `P` regardless of its support.
{
  asserts,
  shirrHead,
  shirrPass1,
  shirrFinal,
  shirrDeltaOnly,
}:
let
  withheld = shirrPass1.resolve shirrHead;
in
{
  construct = [ "C96" ];
  check = asserts (
    withheld.flag == "P"
    && !(builtins.tryEval withheld.included).success
    && !(builtins.tryEval (shirrPass1.verdict shirrHead)).success
    && !(builtins.tryEval shirrDeltaOnly).success
    &&
      shirrFinal.resolve shirrHead == {
        flag = "T";
        included = false;
      }
    &&
      shirrPass1.resolve "furl:damask" == {
        flag = "P";
        included = true;
      }
  );
}
