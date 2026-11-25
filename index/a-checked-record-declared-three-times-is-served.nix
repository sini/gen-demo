{
  title = "a checked record declared three times is served";
  adr = "0039 (den-hoag-7fb0k)";
  what = "`a-checked-record-declared-three-times-is-served`: a gen `submodule` with a check laid on, by its check's functor replaced and by nixpkgs `addCheck`, declared three and four times, bare and below gen `attrsOf`, in gen's `evalModuleTree`, serves `{ a = 1; }` as nixpkgs' `lib.evalModules` serves it and refuses `{ a = 2; }`, where from three declarations the one-value step compared the module set's `emptyValue` and refused the valid value (\"the option `a' is used but not defined\")";
}
