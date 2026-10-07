{
  title = "instance names deciding their kind compose on both constructs";
  adr = "0033";
  what = "`lappetKnob`: a kind read off the declaring tree's own `config.schema.lappet`, decided by a separate value-plane option (off and on) or by the construct's own instance names (`config.lappets ? l1`), read through `mkInstanceRegistry` and through its `attrsOf (mkInstanceType …)` sibling; both constructs give the same instance in all three arms. An instance VALUE deciding its own kind aborts on both, gen-schema's enumerated exception, pinned there";
}
