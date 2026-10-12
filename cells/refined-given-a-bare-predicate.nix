# `refined-given-a-bare-predicate-refuses` — den-hoag-ub19x, ADR-0025 item 1. gen-schema's `refined` given
# a refinement that is not a `{ check; message; }` record (a bare predicate above all) refuses BY NAME at
# formation, alone and inside a list, where it used to form and abort uncatchably at the first value
# check. The record twins form and still enforce, so a `refined` refusing everything cannot pass. The
# refusal is by name in the `refusals` row `refined-given-a-bare-predicate`.
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  positive = v: v > 0;
  record = {
    check = positive;
    message = "must be positive";
  };
  decides = e: (builtins.tryEval (builtins.deepSeq e null)).success;
  forms = refinements: decides (schema.refined T.int refinements).name;
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.spool = genMerge.mkOption { inherit type; }; }
      { spool = v; }
    ]).config.spool;
in
{
  construct = [ "refined-given-a-bare-predicate-refuses" ];
  check = asserts (
    # the record twins form, and still enforce
    forms record
    && forms [ record ]
    && read (schema.refined T.int record) 4 == 4
    && !(decides (read (schema.refined T.int record) (-1)))
    # a bare predicate refuses at formation, alone and inside a list, and checking a value against it
    # is therefore never reached
    && !(forms positive)
    && !(forms [
      record
      positive
    ])
    && !(decides (read (schema.refined T.int positive) 4))
  );
}
