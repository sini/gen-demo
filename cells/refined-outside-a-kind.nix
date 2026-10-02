# `refined-outside-a-kind` — C131, den-hoag-refined-outside-kind-silent-1jlsq. gen-schema's `refined`
# in a plain option, outside any schema kind: `spool`, refined positive, refuses `-1` catchably, alone
# and as a `listOf` element, where it used to admit both because only a kind's pipeline read the
# refinement. `4` and `[ 4 ]` are the passing twins, so a type refusing every value cannot pass. The
# refusal is by name in `refusals` row 136.
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  spool = schema.refined T.int schema.refinements.positive;
  read =
    type: v:
    (genMerge.evalModuleTree {
      modules = [
        { options.spool = genMerge.mkOption { inherit type; }; }
        { spool = v; }
      ];
    }).config.spool;
  refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
in
{
  construct = [ "C131" ];
  check = asserts (
    read spool 4 == 4
    && read (T.listOf spool) [ 4 ] == [ 4 ]
    && refused spool (-1)
    && refused (T.listOf spool) [
      4
      (-1)
    ]
  );
}
