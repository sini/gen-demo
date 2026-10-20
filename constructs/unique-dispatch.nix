# ── gen-dispatch's `unique` option (den-hoag-ro5cu): a group in which exactly one rule survives
# the exclusive filter is served; a second rule surviving beside it refuses the read of that
# group's actions, naming the group and both rules, rather than firing the tie additively.
{ genDispatch }:
let
  selvedgeActions = genDispatch.mkActions { selvedge = [ "bind" ]; };
  selvedgeRule =
    identity: priority:
    genDispatch.mkRule { inherit identity priority; } { } (
      _id: _ctx: [ (selvedgeActions.bind { by = identity; }) ]
    );
  selvedgeDispatch =
    rules:
    genDispatch.dispatch
      {
        exclusive = true;
        unique = true;
      }
      {
        inherit rules;
        id = "faille";
        context = { };
        match =
          _cond: _id: _ctx:
          true;
        inherit (selvedgeActions) classify;
        groupOrder = [ "selvedge" ];
      };
  selvedgeServed =
    (selvedgeDispatch [
      (selvedgeRule "bind-the-faille" 10)
      (selvedgeRule "bind-the-damask" 0)
    ]).actions.selvedge;
  selvedgeTieRefuses =
    !(builtins.tryEval (
      builtins.deepSeq
        (selvedgeDispatch [
          (selvedgeRule "bind-the-faille" 10)
          (selvedgeRule "bind-the-damask" 10)
        ]).actions.selvedge
        null
    )).success;
in
{
  inherit
    selvedgeActions
    selvedgeRule
    selvedgeDispatch
    selvedgeServed
    selvedgeTieRefuses
    ;
}
