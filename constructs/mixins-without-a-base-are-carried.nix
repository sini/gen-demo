# ── MIXINS WITHOUT A BASE ARE CARRIED ──
# A `user` kind on a schema that declares no `baseModule` (the default, `null`), with one mixin that
# reads nothing off the base and contributes `lst = [ "mx" ]` and an option `mxo`. An absent base is
# the empty record, so the mixin is carried exactly as over `baseModule = { }`. The same mixin over a
# function-module base, which the record algebra cannot read, is refused by name (catchably).
{ genMerge, inputs }:
let
  mwbSchema = inputs.gen.lib.substrate.schema;
  mwbMixin = mwbSchema.mkMixin { } (_: {
    lst = [ "mx" ];
    mxo = genMerge.mkOption {
      type = genMerge.types.str;
      default = "m";
    };
  });
  mwbUser =
    base:
    (genMerge.evalModuleTree { } [
      {
        options.schema = mwbSchema.mkSchemaOption (
          {
            collections.lst.default = [ ];
            mixins = [ mwbMixin ];
          }
          // base
        );
      }
      { config.schema.user.lst = [ "own" ]; }
    ]).config.schema.user;
  mwbKind = mwbUser { };
  mwbFnBase = mwbUser { baseModule = _: ({ ... }: { }); };
in
{
  mwbRead = {
    pub = mwbKind.lst;
    opt = builtins.elem "mxo" (builtins.attrNames mwbKind.options);
    inst = (genMerge.evalModuleTree { } [ mwbKind ]).config.mxo or "ABSENT";
    fnBaseServed = (builtins.tryEval (builtins.deepSeq mwbFnBase.lst mwbFnBase.lst)).success;
  };
}
