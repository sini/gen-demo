{
  title = "a Merge Strategy serves the value its warning describes";
  adr = "0027, 34i06";
  what = "`merge-strategy-serves-what-it-warns`: under gen-bind's `system-wins`, nixpkgs' `lib.evalModules` serves a module the `spool` value the hosted module system supplies through `_module.args`, and the merge validator warns that the binding was dropped, where gen-bind served the binding while warning that it had dropped it; `bind-wins` over the same evaluation is the control";
}
