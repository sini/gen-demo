# `redeclared-instance-types-of-different-kinds-mint-apart` — den-hoag-2vtgj. An embedding option declared
# twice, or redeclared beside a plain submodule, is a join
# gen-merge constructs from its two declarations, so its type is identified by them, each by its mark: a `fichu`
# whose `trim` is declared twice over a `quilling` instance and one declared twice over a `furbelow` instance, in
# two schemas so their name cannot separate them, read two marks and `kindEq` decides them `false`; so does the
# pair redeclared beside one plain `submodule`. Before, every such join minted one constant, the two `fichu`s one
# mark, separated only by `kindEq`'s refusal. The control: the lone pair still reads two marks.
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  kindsOf =
    ms:
    (genMerge.evalModuleTree { } ([ { options.schema = schema.mkSchemaOption { }; } ] ++ ms))
    .config.schema;
  embedded = kindsOf [
    {
      config.schema.quilling.options.coils = genMerge.mkOption { type = T.int; };
      config.schema.furbelow.options.tier = genMerge.mkOption { type = T.str; };
    }
  ];
  trim = ty: { config.schema.fichu.options.trim = genMerge.mkOption { type = ty; }; };
  hem = T.submodule { options.hem = genMerge.mkOption { default = ""; }; };
  lone = k: (kindsOf [ (trim (schema.mkInstanceType { } k)) ]).fichu;
  twice =
    k:
    (kindsOf [
      (trim (schema.mkInstanceType { } k))
      (trim (schema.mkInstanceType { } k))
    ]).fichu;
  plus =
    k:
    (kindsOf [
      (trim (schema.mkInstanceType { } k))
      (trim hem)
    ]).fichu;
  decided = e: builtins.tryEval (builtins.deepSeq e e);
  apart =
    f:
    let
      q = f embedded.quilling;
      b = f embedded.furbelow;
      eq = decided (schema.kindEq q b);
    in
    q.__mint.minted != b.__mint.minted && eq.success && eq.value == false;
in
{
  construct = [ "redeclared-instance-types-of-different-kinds-mint-apart" ];
  check = asserts (apart twice && apart plus && apart lone);
}
