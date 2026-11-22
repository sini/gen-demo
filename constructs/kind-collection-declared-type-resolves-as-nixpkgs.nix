# ── A KIND'S COLLECTION DECLARES ITS WHOLE TYPE, AND RESOLVES AS AN OPTION OF THAT TYPE DOES ──
# A `user` kind's `classes` collection declares `type = listOf str` and its `env` collection
# `type = attrsOf (attrsOf int)` (gen-schema's opt-in `type` field). The type merges the definitions,
# so an element `mkIf false` discharges is not counted, a property two levels down is resolved, and an
# element the type's check rejects is refused. Its `shell` collection, `type = nullOr str` with
# `default = null`, is served its definition, as an option of that type with that default is. Its
# `hosts` collection, `type = nonEmptyListOf str` with `default = [ "localhost" ]`, whose only definition
# `mkIf false` discharges, is its default alone, as an option of that type with that default is.
# Omitted, a collection keeps the inferred lazy container
# (`kind-collection-element-resolves-as-nixpkgs`). A field outside the closed set and `type` beside `merge` are
# each refused by name (`ci/refusals/collection-declaring-a-field-outside-its-closed-set.sh`,
# `ci/refusals/collection-declaring-both-type-and-merge.sh`).
{ genMerge, inputs }:
let
  kcdtSchema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  NT = inputs.nixpkgs.lib.types;
  kcdtUser =
    defs:
    (genMerge.evalModuleTree { } (
      [
        {
          options.schema = kcdtSchema.mkSchemaOption {
            collections.classes = {
              default = [ ];
              type = T.listOf T.str;
            };
            collections.env = {
              default = { };
              type = T.attrsOf (T.attrsOf T.int);
            };
            collections.shell = {
              default = null;
              type = T.nullOr T.str;
            };
            collections.hosts = {
              default = [ "localhost" ];
              type = NT.nonEmptyListOf NT.str;
            };
          };
        }
      ]
      ++ map (d: { config.schema.user = d; }) defs
    )).config.schema.user;
  kcdtKind = kcdtUser [
    {
      classes = [
        (genMerge.mkIf false "nixos")
        "darwin"
      ];
      env.eu = {
        replicas = genMerge.mkIf false 1;
        shards = 2;
      };
      shell = "zsh";
      hosts = genMerge.mkIf false [ "db" ];
    }
  ];
  kcdtWrongElement = (kcdtUser [ { classes = [ 1 ]; } ]).classes;
in
{
  kcdtRead = {
    classCount = builtins.length kcdtKind.classes;
    classes = kcdtKind.classes;
    env = kcdtKind.env;
    shell = kcdtKind.shell;
    hosts = kcdtKind.hosts;
    wrongElementServed =
      (builtins.tryEval (builtins.deepSeq kcdtWrongElement kcdtWrongElement)).success;
  };
}
