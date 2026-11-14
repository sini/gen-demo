{
  title = "a shared closure decision serves a staged keyed tree";
  adr = "0008 §3, 0033, 0039, den-hoag-staged-stratum-inner-eval-nhjxu";
  what = "`a-shared-closure-decision-serves-a-staged-keyed-tree`: keyed modules, a path module stated twice and a declaration reading `options` (so it resolves in a staged pass), at the top and again in a located `submodule` child; the guard's walk publishes its closure decision and the value stratum and the passes re-apply along it, deciding the repeated path against their own holder, and gen-merge reads the value nixpkgs' `lib.evalModules` reads";
}
