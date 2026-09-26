# ── C24 — ADR-0023 (b)'s DECLARED INTERIM, PRICED ON THE CORPUS'S OWN CROSSED PAYLOAD
# (den-hoag-9ivu, ADR-0023). Limb (b) turned the unstated crossing violations into declared
# opt-outs with their price recorded, and site 5's price — `injectAdapter`'s, stated in
# gen-bind's `lib/crossing-adapter-set.nix` — is the only one addressed to a CONSUMER:
# "substrate-built gen TYPE objects cross this boundary. They are inert HERE only because
# `_module.args` is not type-walked by the consuming module system." gen-demo is that
# consumer, so the corpus is where the price stops being a sentence and becomes a reading.
#
# Sites 1 (`applyContracts`) and 4 (`configGate`) are NOT declarable here and this is not an
# omission: each declaration's own (iii) clause states there is no crossing route through any
# shipped Adapter to reach them by — `injectAdapter`, `mkHostedTerminal` and `mkFlakeTerminal`
# all set `bindArgEnv = null`. Site 3 (`resolveThunks`) is already declared, by the thunk-
# authorization rows 20/21 on the T5 plane, and site 6 (`bindFormals`) by C22's terminal.
{ config, genBind }:
let
  c24Payload = config.gen.composed.values;
  c24Crossed = (genBind.crossing.injectAdapter.bindFormals c24Payload { })._module.args;
  # Read at the crossed value's OWN TOP LEVEL, never a transitive walk: the transitive form is
  # the interim's own O-INJ-2 and lives in gen-bind, and a corpus cell restating it would be a
  # second copy of someone else's oracle rather than a consumer's reading.
  c24PlainAt = v: !(builtins.any builtins.isFunction (builtins.attrValues v));
in
{
  inherit c24Payload c24Crossed c24PlainAt;
}
