{
  title = "a leaf `freeformType` folds the undeclared plane";
  adr = "0025 item 1";
  what = "`freeform-leaf-type-folds`: `selvage = \"twill\"` reads `\"twill\"` under `freeformType = types.str` and under a bare `defineType` leaf, where the freeform fold aborted uncatchably; `selvage` and `bobbin` from two files are refused catchably under `str`, and the same two files read both keys under `attrsOf str`";
}
