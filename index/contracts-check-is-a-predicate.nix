{
  title = "a contract's check is a predicate";
  adr = "0025 item 1, 5rz5r";
  what = "`contract-check-result-is-a-boolean`: gen-bind's `contract.mk`/`contract.apply` serve an edge check answering `true` (`selvage`), and refuse catchably one answering the string `\"yes\"`, where gen-bind aborted uncatchably with `expected a Boolean but found a string`; the Boolean check is the control";
}
