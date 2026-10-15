{
  title = "a redeclaration whose types do not merge refuses only the read of that option";
  adr = "0025 item 1, 0039, q36zi";
  what = "`redeclared-type-clash-refuses-only-its-own-read`: one option `loom` declared `int` and `str` beside an unrelated `weft`, under `genMerge.evalModuleTree` and `lib.evalModules`; both engines serve `config.weft` and `options.weft.default` and refuse `loom` by name, catchably, at its value, its option record and its type, where gen-merge refused every read of the evaluation";
}
