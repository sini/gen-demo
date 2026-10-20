{
  title = "a deep attrs fold joins a fleet";
  adr = "0034";
  what = "`folds-merge-attrs-deep-fleet`: `folds.mergeAttrsDeep` joins two hosts' `nixosConfigurations`, `deploy.nodes.<h>.hostname` and `colmena` fragments and an equal repeated leaf into one record, leaving a lone contributor unforced, where the shallow `folds.mergeAttrs` refuses the shared sub-key";
}
