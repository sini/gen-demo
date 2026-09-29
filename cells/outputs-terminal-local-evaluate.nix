# `outputs-terminal-local-evaluate` — C101, den-hoag-52hn7. The terminal's `wrapUnit` over
# `tasselBody` is the consumer's own fold of it, `{ tassel = 1; fringe = 2; }`, and not the Body
# handed back; no position is offered (`bindFormals`, `bindArgEnv` and `wrapFn` are `null`), no config
# is located (`locateConfig = null`), and gen-bind's own `mkAdapter` accepts the record.
{
  asserts,
  genBind,
  tasselBody,
  tasselTerminal,
}:
let
  a = tasselTerminal.adapter;
in
{
  construct = [ "C101" ];
  check = asserts (
    a.wrapUnit tasselBody [ ] == {
      tassel = 1;
      fringe = 2;
    }
    && tasselTerminal.locateConfig == null
    && a.bindFormals == null
    && a.bindArgEnv == null
    && a.wrapFn == null
    && genBind.crossing.isOk (genBind.crossing.mkAdapter a)
  );
}
