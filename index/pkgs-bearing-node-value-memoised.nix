{
  title = "a pkgs-bearing node value, memoised";
  adr = "0008 §2, 0025 item 1";
  what = "`pkgs-bearing-node-value`: C66's chain with node values carrying `pkgs`, whose walk meets nixpkgs' lazy throws, goes through `genMemo.propagateEager` and reads the cold build's `[ 211 \"hello\" ]`; its hash is `null` (always-dirty) where plain values hash";
}
