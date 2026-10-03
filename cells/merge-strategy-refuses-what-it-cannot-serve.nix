# `merge-strategy-refuses-what-it-cannot-serve` — C161, den-hoag-34i06. A module whose every formal is
# bound is called by gen-bind at wrap time, so no module-system value can reach it: a `system-wins`
# collision there is refused catchably, where gen-bind served the binding while warning that it had
# dropped it. `bind-wins` over the same fully-applied module is the control: the binding is served
# and the warning says the module-system value was shadowed.

{ asserts, spoolUnderStrategy }:

let
  sw = spoolUnderStrategy "full" "system-wins";
  bw = spoolUnderStrategy "full" "bind-wins";
in

{
  construct = [ "C161" ];
  check = asserts (
    !(builtins.tryEval (builtins.deepSeq sw.warnings null)).success
    && bw.out == "cotton"
    &&
      bw.warnings == [ "gen-bind: binding 'spool' collision — bind-wins, module-system value shadowed" ]
  );
}
