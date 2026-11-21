# ── A KIND'S COLLECTION DECLARES ITS WHOLE TYPE, AND RESOLVES AS AN OPTION OF THAT TYPE DOES ──
# A `user` kind's `classes` collection declares `type = listOf str` and its `env` collection
# `type = attrsOf (attrsOf int)` (gen-schema's opt-in `type` field). The type merges the definitions,
# so an element `mkIf false` discharges is not counted, a property two levels down is resolved, and an
# element the type's check rejects is refused. Its `shell` collection, `type = nullOr str` with
# `default = null`, is served its definition, as an option of that type with that default is.
# A collection declaring a type and no default, which the kind never defines, reads its type's empty
# value (`[ ]`, `null`) and is refused by name where the type states none (`str`), as an option of the
# type with no definition is. Omitted, a collection keeps the inferred lazy container
# (`kind-collection-element-resolves-as-nixpkgs`). A field outside the closed set and `type` beside `merge` are
# each refused by name (`ci/refusals/collection-declaring-a-field-outside-its-closed-set.sh`,
# `ci/refusals/collection-declaring-both-type-and-merge.sh`).
{ genMerge, inputs }:
let
  kcdtSchema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
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
            # declaring a type and no default, and never defined by the kind
            collections.aliases.type = T.listOf T.str;
            collections.owner.type = T.nullOr T.str;
            collections.title.type = T.str;
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
    wrongElementServed =
      (builtins.tryEval (builtins.deepSeq kcdtWrongElement kcdtWrongElement)).success;
    aliases = kcdtKind.aliases;
    owner = kcdtKind.owner;
    titleServed = (builtins.tryEval (builtins.deepSeq kcdtKind.title kcdtKind.title)).success;
  };
}
