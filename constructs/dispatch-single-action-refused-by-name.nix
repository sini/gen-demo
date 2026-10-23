# ── gen-dispatch's `produce : id -> ctx -> [ action ]` contract: a policy returning one action
# instead of a list refuses the read of its group's actions by name, rather than aborting the
# evaluation with an uncatchable builtin type error.
{ genDispatch }:
let
  weftActions = genDispatch.mkActions { weft = [ "thread" ]; };
  weftDispatch =
    policy:
    (genDispatch.dispatch { } {
      rules = [ (genDispatch.fromFunction policy) ];
      id = "selvage";
      context = {
        loom = 1;
      };
      match = genDispatch.fromFunctionMatch;
      inherit (weftActions) classify;
      groupOrder = [ "weft" ];
    }).actions;
  weftListServed = weftDispatch ({ loom, ... }: [ (weftActions.thread { by = "list"; }) ]);
  weftSingleRefuses =
    !(builtins.tryEval (
      builtins.deepSeq (weftDispatch ({ loom, ... }: weftActions.thread { by = "single"; })) null
    )).success;
in
{
  inherit
    weftActions
    weftDispatch
    weftListServed
    weftSingleRefuses
    ;
}
