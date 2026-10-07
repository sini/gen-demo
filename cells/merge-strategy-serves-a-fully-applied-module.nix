# `merge-strategy-serves-a-fully-applied-module` — C161, den-hoag-34i06. A module whose every formal is
# bound is still a function of the module system's call args once gen-bind wraps it, so under
# `system-wins` nixpkgs' own `lib.evalModules` serves it the `spool` value the hosted module system
# supplies through `_module.args`, and the merge validator warns that the binding was dropped, as on
# the partial path (C160). gen-bind called such a module at wrap time and refused the collision
# catchably, so `system-wins` could not be served there. `bind-wins` over the same fully-applied module
# is the control: the binding is served and the warning says the module-system value was shadowed.

{
  asserts,
  lib,
  spoolUnderStrategy,
}:

let
  sw = spoolUnderStrategy "full" "system-wins";
  bw = spoolUnderStrategy "full" "bind-wins";
in

{
  construct = [ "merge-strategy-serves-a-fully-applied-module" ];
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
