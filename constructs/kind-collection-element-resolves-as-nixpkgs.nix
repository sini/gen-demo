# ── A KIND'S COLLECTION RESOLVES ITS ELEMENTS AS NIXPKGS DOES ──
# A `user` kind's `classes` collection holds a list whose elements carry `mkIf true` and
# `mkDefault`, and its `metadata` collection a key under `mkForce` over a later plain definition of
# that key. The module system resolves each element's priority when the element is read, as a
# `listOf`/`attrsOf` option does. A `classes` defined as a string is refused by name, a catchable
# refusal, where it once reached the list fold and aborted.
{ genMerge, inputs }:
let
  kceSchema = inputs.gen.lib.substrate.schema;
  kceUser =
    defs:
    (genMerge.evalModuleTree { } (
      [
        {
          options.schema = kceSchema.mkSchemaOption {
            collections.classes.default = [ ];
            collections.metadata.default = { };
          };
        }
      ]
      ++ map (d: { config.schema.user = d; }) defs
    )).config.schema.user;
  kceKind = kceUser [
    {
      classes = [
        (genMerge.mkIf true "nixos")
        (genMerge.mkDefault "darwin")
      ];
      metadata.region = genMerge.mkForce "eu";
    }
    { metadata.region = "us"; }
  ];
  kceWrongShape = (kceUser [ { classes = genMerge.mkDefault "x"; } ]).classes;
in
{
  kceRead = {
    classes = kceKind.classes;
    metadata = kceKind.metadata;
    wrongShapeServed = (builtins.tryEval (builtins.deepSeq kceWrongShape kceWrongShape)).success;
  };
}
