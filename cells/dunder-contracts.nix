# `dunder-contracts` — C85, den-hoag-4kh.53.53 (G4). Four records that cross from one gen library into
# another carry exactly the `__` keys their owners state as R12 contracts (each owner's AGENTS.md):
# gen-aspects' node data projected by gen-select's registry adapter carries gen-select's `__identity`;
# gen-aspects' `keyRef` (read by gen-link) carries `__keyRef`; a gen-schema kind value (read by
# gen-select) carries gen-algebra's `__mint` and gen-schema's `__sealed` beside Nix's own `__functor`;
# a gen-select selector (read by gen-dispatch) carries `__sel`. Red when any of them grows ANY new `__`
# key, declared or not, or loses one. This is the corpus declaration of those crossings; whether each
# key has its contract line is the census's to say, not this cell's.
{
  asserts,
  c16Ctx,
  genAspects,
  genMerge,
  genSelect,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  dunder = v: builtins.filter (k: builtins.substring 0 2 k == "__") (builtins.attrNames v);
  kind =
    (genMerge.evalModuleTree {
      modules = [
        { options.schema = schema.mkSchemaOption { }; }
        { config.schema.selvage.options.ends = genMerge.mkOption { type = genMerge.types.int; }; }
      ];
    }).config.schema.selvage;
in
{
  construct = [ "C85" ];
  check = asserts (
    dunder (c16Ctx.data "hemline/placket") == [ "__identity" ]
    && dunder (genAspects.keyRef "mill/stitch") == [ "__keyRef" ]
    &&
      dunder kind == [
        "__functor"
        "__mint"
        "__sealed"
      ]
    && dunder (genSelect.kind kind) == [ "__sel" ]
  );
}
