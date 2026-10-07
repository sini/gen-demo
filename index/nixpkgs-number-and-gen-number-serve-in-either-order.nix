{
  title = "nixpkgs' number and gen's number serve in either order";
  adr = "0025 item 1, 0034, 0039, kawe8";
  what = "`number-redeclared-either-order`: one option `loom` declared by nixpkgs' `number` (`either int float`) and gen-merge's `number`, in both orders, under `genMerge.evalModuleTree` and `lib.evalModules`, equals its nixpkgs × nixpkgs twin at 1, at 1.5 and inside `either number str`, record name `either` included, where it refused in both orders on both engines; the closing cases, a string refused in both orders on both engines as its twin is, and nixpkgs' `addCheck number (v != 7)` beside gen-merge's `number` refusing 7 in gen's evaluation in both orders (the meet); the control, gen × gen `number`, keeps gen's record";
}
