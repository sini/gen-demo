# `schema-option-redeclared-reads-its-kinds` — C83, den-hoag-px98p. One `mkSchemaOption` value is
# declared by two modules, the shape of a framework and a consumer both declaring the registry, and
# the redeclared option reads its introspection exactly as the option declared once does: its type,
# `schema`, carries the entry type's construction relation, so one construction declared twice is
# one option and the introspection module is imported once. C78 reads the kinds through the same
# redeclaration; this cell reads the schema-level views over them. Before, the two declarations
# unioned their module sets, the introspection module was imported twice, and `_kindNames` refused
# "read-only, but it is defined 2 times".
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  registry = schema.mkSchemaOption { };
  read =
    decls:
    (genMerge.evalModuleTree {
      modules = decls ++ [
        { config.schema.selvage = { }; }
        { config.schema.bobbin.parent = "selvage"; }
      ];
    }).config.schema;
  once = read [ { options.schema = registry; } ];
  twice = read [
    { options.schema = registry; }
    { options.schema = registry; }
  ];
in
{
  construct = [ "C83" ];
  check = asserts (
    twice._kindNames == [
      "bobbin"
      "selvage"
    ]
    # control: the value the redeclaration must equal is the option declared once
    && twice._kindNames == once._kindNames
    && twice._topology == once._topology
    && twice._edges == once._edges
  );
}
