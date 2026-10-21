{
  title = "a kind fold refuses naming its contributor";
  adr = "0010 §2, 0025 item 1, bluqd";
  what = "`typed-sited-fold`: a kind whose `foldFragments = folds.typed int folds.same` (gen-types' `int`) over two claims in one dedup group, read through `resolveClaims`, resolves the agreeing well-typed pair to `22` and refuses the agreeing ill-typed pair `\"22\"`, `\"22\"`, while the same pair through the untyped `folds.same` resolves to `\"22\"`. The fold is handed contributor edges `[ { site; value; } ]`, each sited `claim at path <json>`, so the refusal names the claim: `gen-scope.folds.typed: key 'port': fragment from claim at path [0]: expected type 'int' …`. Before, a kind fold was handed bare values, `folds.typed` did not exist, and an ill-typed fragment folded at rc 0";
}
