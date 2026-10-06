# `withheld-negative-support` — C96, den-hoag-ea3j4. At pass 1 (`complete = false`) the shirr atom
# is derived through `not smocked:damask`, and it reads `P` with `included` refusing (`tryEval`
# fails) and `verdict` refusing too. Pass 2, handed pass 1's record as `prior`, adds
# `smocked:damask` and answers it `T`, out; a pass 2 that drops pass 1's declarations is refused.
# The control is the negation-free `furl:damask` on the same pass-1 record, served `P`, in. Reds on
# a gen-program that serves a derived atom `included = true` under `P` regardless of its support.
# The tuck cycle is `U` at pass 1, and pass 2's fact `pleat:damask` settles it: `tuck:damask` is
# `T`, out. Reds on a gen-program that carries a prior pass's `undefined` atoms across the boundary.
{
  asserts,
  shirrHead,
  shirrPass1,
  shirrFinal,
  shirrDeltaOnly,
  tuckHead,
  tuckPass1,
  tuckFinal,
}:
let
  withheld = shirrPass1.resolve shirrHead;
in
{
  construct = [ "growing-relation-withholds-a-negated-answer" ];
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
    && (tuckPass1.resolve tuckHead).flag == "U"
    &&
      tuckFinal.resolve tuckHead == {
        flag = "T";
        included = false;
      }
  );
}
