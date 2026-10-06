# `aspect-twin-kinds-one-mktype` — C115, den-hoag-1fo91 (ADR-0034). Two gen-aspects schemas, each
# built by its own `mkAspectSchema` call over the corpus cnf (`aspect-cnf.nix`), each declare an
# `aspect` kind, and both kinds are constructed over gen-aspects' ONE shared `mkType`. `kindEq`
# admits them as one kind. Upstream Nix and Determinate used to refuse the pair, naming the sealed
# `mkType` component as differing, while Lix admitted it: gen-schema selected the function into a
# fresh slot, and gen-algebra's sealed copy re-wrapped it in another (den-hoag-2rs1f). Two
# plain gen-schema kinds over two lambdas of one text are still refused, so a `kindEq` that admits
# every pair cannot pass.
{
  asserts,
  genAspects,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  cnf = import ../aspect-cnf.nix;
  # one fresh `mkAspectSchema` call per application
  aspectKind =
    _:
    let
      s = genAspects.mkAspectSchema cnf;
    in
    (genMerge.evalModuleTree { } [
      { options.schema = s.schemaOption; }
      (s.mkAspectModule { })
      { config.schema.aspect = { }; }
    ]).config.schema.aspect;
  # two lambdas of one text: genuinely different functions
  shaped =
    { defs, kind, ... }:
    {
      __functor = _: _: { imports = map (d: d.value) defs; };
      inherit kind;
    };
  shaped' =
    { defs, kind, ... }:
    {
      __functor = _: _: { imports = map (d: d.value) defs; };
      inherit kind;
    };
  selvage =
    mkType:
    (genMerge.evalModuleTree { } [
      { options.schema = schema.mkSchemaOption { inherit mkType; }; }
      { config.schema.selvage.options.ends = genMerge.mkOption { type = genMerge.types.int; }; }
    ]).config.schema.selvage;
  decided = e: (builtins.tryEval e).success;
in
{
  construct = [ "twin-aspect-kinds-over-one-shared-mktype-are-one-kind" ];
  check = asserts (
    schema.kindEq (aspectKind 1) (aspectKind 2)
    && schema.kindEq (selvage shaped) (selvage shaped)
    && !(decided (schema.kindEq (selvage shaped) (selvage shaped')))
  );
}
