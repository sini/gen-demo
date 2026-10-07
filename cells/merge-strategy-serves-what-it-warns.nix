# `merge-strategy-serves-what-it-warns` — C160, den-hoag-34i06. Under gen-bind's `system-wins`, nixpkgs'
# own `lib.evalModules` serves the module the value the hosted module system supplies for the bound
# name (here from `_module.args`), and the merge validator's warning says the binding was dropped.
# gen-bind served the binding while warning that it had dropped it. `bind-wins` over the same
# evaluation is the control: the binding is served and the warning says the module-system value was
# shadowed.

{
  asserts,
  lib,
  spoolUnderStrategy,
}:

let
  sw = spoolUnderStrategy "partial" "system-wins";
  bw = spoolUnderStrategy "partial" "bind-wins";
in

{
  construct = [ "merge-strategy-serves-the-value-its-warning-describes" ];
  check = asserts (
    sw.out == "linen"
    &&
      map (lib.hasPrefix "gen-bind: binding 'spool' collision — system-wins, binding value dropped") sw.warnings
      == [ true ]
    && bw.out == "cotton"
    &&
      map (lib.hasPrefix "gen-bind: binding 'spool' collision — bind-wins, module-system value shadowed") bw.warnings
      == [ true ]
  );
}
