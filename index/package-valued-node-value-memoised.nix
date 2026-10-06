{
  title = "a package-valued node value, memoised";
  adr = "0008 §1, 0025 item 1";
  what = "`drv-bearing-node-value`: a node whose value is `hello` overlaid with `//` (same drvPath) goes through `genMemo.propagateEager`; an edit to the overlay reaches its dependent and reads the cold build's `\"woven\"`, and the package hashes (its trace hash is a string, not always-dirty); `spelled-stand-in-node-value`: a node value edited from `{ outPath = …; }` to `{ __outPath = …; }`, the stand-in the plane writes for `outPath`, moves and reaches its dependent (den-hoag-x67vn, the key escape)";
}
