# `kind-value-mounts-in-nixpkgs` — den-hoag-r05lc and den-hoag-e5whp. A gen kind value is a module
# (`__functor`), and a consumer mounts it in a nixpkgs `lib.evalModules` submodule. gen-merge's
# collector keys (`__reservedKeys` on every importing kind entry def, `__keyEq` on a kind composing
# a parent) ride on the RECORD of a functor module, which nixpkgs never collects, so each mount reads
# what the same definitions mounted raw read. Before, nixpkgs refused an attrset entry ("unsupported
# attribute `__reservedKeys'"), a parented kind ("unsupported attribute `__keyEq'"), and a function
# entry under an open freeform silently gained a `__reservedKeys` key. Each arm is compared against
# its raw-definition mount in the same cell, so the cell reads the kind value, not two defaults.
{
  asserts,
  genAspects,
  genMerge,
  genSchema,
  lib,
}:
let
  mountWith =
    extra: kind: defs:
    (lib.evalModules {
      modules = [
        {
          options.spool = lib.mkOption {
            type = lib.types.submodule {
              imports = [
                kind
                extra
              ];
            };
            default = { };
          };
        }
        { config.spool = defs; }
      ];
    }).config.spool;
  mount = mountWith { };
  # an open freeform (den's aspect shape), where a stray key would land silently
  mountFree = mountWith { freeformType = lib.types.lazyAttrsOf lib.types.anything; };
  names = v: builtins.filter (n: n != "_module") (builtins.attrNames v);
  same = a: b: builtins.toJSON a == builtins.toJSON b;

  genInt = genMerge.mkOption {
    type = genMerge.types.int;
    default = 1;
  };
  nixInt = lib.mkOption {
    type = lib.types.int;
    default = 1;
  };

  kinds =
    decls:
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { }; }
      { config.schema = decls; }
    ]).config.schema;
  spindle = decl: (kinds { spindle = decl; }).spindle;

  aspectSchema = genAspects.mkAspectSchema { keySemantics.selvage.category = "class"; };
  aspectKind =
    decl:
    (genMerge.evalModuleTree { } [
      { options.schema = aspectSchema.schemaOption; }
      (aspectSchema.mkAspectModule { })
      { config.schema.aspect = decl; }
    ]).config.schema.aspect;
in
{
  construct = [ "a-kind-value-mounts-in-nixpkgs-as-its-definition" ];
  check = asserts (
    # an attrset entry carrying options
    same (mount (spindle { options.gauge = genInt; }) { gauge = 5; }) (
      mount { options.gauge = nixInt; } { gauge = 5; }
    )
    # an attrset entry importing a module: the def the record-carrying wrapper returns
    &&
      same
        (mount (spindle {
          options.gauge = genInt;
          imports = [ { options.weft = genInt; } ];
        }) { gauge = 5; })
        (
          mount {
            options.gauge = nixInt;
            imports = [ { options.weft = nixInt; } ];
          } { gauge = 5; }
        )
    # a function entry under an open freeform gains no key
    && same (names (mountFree (spindle ({ lib, ... }: { })) { })) (
      names (mountFree ({ lib, ... }: { }) { })
    )
    # a kind composing a parent (`__keyEq` on the record)
    &&
      same
        (names (
          mount
            (kinds {
              bobbin.options.weft = genInt;
              spindle = {
                inherits = [ "bobbin" ];
                options.gauge = genInt;
              };
            }).spindle
            { }
        ))
        (
          names (
            mount {
              imports = [ { options.weft = nixInt; } ];
              options.gauge = nixInt;
            } { }
          )
        )
    # gen-aspects' aspect kind: an attrset entry carrying options, and a function entry
    && same (mount (aspectKind { options.gauge = nixInt; }) { gauge = 5; }) (
      mount { options.gauge = nixInt; } { gauge = 5; }
    )
    && same (names (mountFree (aspectKind ({ lib, ... }: { })) { })) (
      names (mountFree ({ lib, ... }: { }) { })
    )
  );
}
