{
  title = "a self-referential node value, memoised";
  adr = "0008 §2, 0025";
  what = "`self-referential-node-value`: a chain whose node values each carry themselves goes through `genMemo.propagateEager` and reads the cold build's `[ 211 200 ]`; its hash is `null` (always-dirty) where plain values hash";
}
