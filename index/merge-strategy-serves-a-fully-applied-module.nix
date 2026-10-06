{
  title = "a Merge Strategy serves a fully-applied module";
  adr = "0027, 34i06";
  what = "`merge-strategy-serves-a-fully-applied-module`: on a fully-applied module, which gen-bind wraps as a function of the module system's call args, nixpkgs' `lib.evalModules` serves the `spool` value the hosted module system supplies through `_module.args` under `system-wins`, and the merge validator warns that the binding was dropped, where gen-bind called the module at wrap time and refused the collision catchably; `bind-wins` over the same module is the control";
}
