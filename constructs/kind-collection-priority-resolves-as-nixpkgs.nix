# ── A KIND'S COLLECTION RESOLVES ITS DEFINITIONS' PRIORITIES AS NIXPKGS DOES ──
# A `user` kind's `classes` collection holds one `mkDefault` definition (the reported shape); an
# `admin` kind's holds a plain definition over a `mkDefault` one and a `mkIf false` one, and its
# `metadata` collection a plain definition under a `mkForce` one. The module system resolves each
# definition's priority before the collection's strategy folds, so every value is the one nixpkgs
# serves for the same definitions of an option.
{ genMerge, inputs }:
let
  kcpSchema = inputs.gen.lib.substrate.schema;
  kcpKinds =
    (genMerge.evalModuleTree { } [
      {
        options.schema = kcpSchema.mkSchemaOption {
          collections.classes.default = [ ];
          collections.metadata.default = { };
        };
      }
      {
        config.schema.user.classes = genMerge.mkDefault [ "homeManager" ];
        config.schema.admin = {
          classes = [ "nixos" ];
          metadata.region = "eu";
        };
      }
      {
        config.schema.admin = {
          classes = genMerge.mkDefault [ "homeManager" ];
          metadata = genMerge.mkForce { tier = "prod"; };
        };
      }
      { config.schema.admin.classes = genMerge.mkIf false [ "darwin" ]; }
    ]).config.schema;
in
{
  kcpRead = {
    userClasses = kcpKinds.user.classes;
    adminClasses = kcpKinds.admin.classes;
    adminMetadata = kcpKinds.admin.metadata;
  };
}
