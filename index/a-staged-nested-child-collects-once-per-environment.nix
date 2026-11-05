{
  title = "a staged nested child collects once per environment";
  adr = "0016 ruling 7, 0019, 0033";
  what = "`a-staged-nested-child-collects-once-per-environment`: a gen-native nested child whose declaration reads `options` in its shape runs its staged passes and serves `{ a = 1; b = 2; c = 4; d = 5; }` at one level and at two, as the same modules serve at the root; its located walks and its passes each decide their keyed closure once";
}
