# `four-tier-unset-reasons` — C114, den-hoag-zakjg U4 (ADR-0029, "nothing vanishes silently"). One
# record per reason gen-merge's `bandedLeaves` (U1) gives for moving nothing, each read from a REAL
# evaluation of the root and each carried into `joinedTrace`'s `unset` half while the environment's
# `T` moves and the receiver reads it:
#   · default-only, from the declared default (k6: `defaulted = true`) and from `mkOptionDefault`
#     (k5: `defaulted = false`), both at priority 1500;
#   · no definition: `x` declared with no default and defined by nobody;
#   · freeform: `x` undeclared, defined on the freeform plane, so it does not move although it has a
#     value.
#
# Red: an `innerOf` that answers `null` for the root (a contributor whose record was dropped) reads
# an empty `unset` half.
{ asserts, fourTier }:
let
  withRoot =
    args:
    let
      c = fourTier.channel (
        {
          contributions = {
            r = [ ];
            t = [ "T" ];
          };
        }
        // args
      );
    in
    {
      inherit (c) moved received;
      joined = map (e: e.contributor) c.joined.joined;
      inherit (c.joined) unset;
      unaccounted = map (r: r.scope) c.joined.unaccounted;
    };
  expect = rootRecord: {
    moved = [ "T" ];
    received = "T";
    joined = [ "t" ];
    unset = [
      (
        {
          scope = "r";
          loc = [ "x" ];
        }
        // rootRecord
      )
    ];
    unaccounted = [ ];
  };
in
{
  construct = [ "C114" ];
  check = asserts (
    withRoot { } == expect {
      reason = "unset: default-only";
      priority = 1500;
      defaulted = true;
    }
    &&
      withRoot {
        contributions = {
          r = fourTier.cases.k5.r;
          t = [ "T" ];
        };
      } == expect {
        reason = "unset: default-only";
        priority = 1500;
        defaulted = false;
      }
    &&
      withRoot { evals.r = fourTier.unsetEvals.noDefinition; } == expect {
        reason = "unset: no definition";
      }
    && withRoot { evals.r = fourTier.unsetEvals.freeform; } == expect { reason = "unset: freeform"; }
  );
}
