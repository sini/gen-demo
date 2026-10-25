# `instance-types-of-different-kinds-mint-apart` — den-hoag-dwln8. An instance type is identified by
# what it is constructed from: the kind (by its mark), `strict` and `extraModules`, never the module
# list gen-schema writes from them. So a `fichu` whose `trim` holds a `quilling` instance and a `fichu`
# whose `trim` holds a `furbelow` instance, declared in two schemas so their name cannot separate them,
# read two marks, and `kindEq` decides them `false`. Before, both instance types minted one constant
# and the two `fichu`s one mark, separated only by `kindEq`'s refusal at a sealed `trim` type. Two
# instance types of one kind are one type. The control: a `fichu` embedding `submodule { }`, whose
# mark is pinned and did not move.
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  kindsOf =
    m:
    (genMerge.evalModuleTree { } [
      { options.schema = schema.mkSchemaOption { }; }
      m
    ]).config.schema;
  embedded = kindsOf {
    config.schema.quilling.options.coils = genMerge.mkOption { type = T.int; };
    config.schema.furbelow.options.tier = genMerge.mkOption { type = T.str; };
  };
  fichu =
    ty: (kindsOf { config.schema.fichu.options.trim = genMerge.mkOption { type = ty; }; }).fichu;
  overQuilling = fichu (schema.mkInstanceType { } embedded.quilling);
  overFurbelow = fichu (schema.mkInstanceType { } embedded.furbelow);
  decided = e: builtins.tryEval (builtins.deepSeq e e);
  kindEq = decided (schema.kindEq overQuilling overFurbelow);
  twins = decided (
    T.typeEq (schema.mkInstanceType { } embedded.quilling) (schema.mkInstanceType { } embedded.quilling)
  );
in
{
  construct = [ "instance-types-of-different-kinds-mint-apart" ];
  check = asserts (
    overQuilling.__mint.minted != overFurbelow.__mint.minted
    && kindEq.success
    && kindEq.value == false
    && twins.success
    && twins.value
    &&
      (fichu (T.submodule { })).__mint.minted
      == "schemakind:cf6cf7874fc6f9d4a62a6b8adbae2953c2fb2a62ec540eb75904fdc643b0510d"
  );
}
