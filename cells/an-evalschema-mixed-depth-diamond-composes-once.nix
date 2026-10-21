# `an-evalschema-mixed-depth-diamond-composes-once` — den-hoag-evalschema-mixed-depth-twin-s2xz6.
# Under `evalSchema`, `cloth` inherits `selvage` directly and through `warp`, which is one level
# shallower (a mixed-depth diamond). Every kind is one node of the module graph (ADR-0012), so the
# tree builds each kind once and every child composes that construction: `selvage` contributes once
# to `cloth`, in gen-merge and in a nixpkgs `lib.evalModules` mount alike, and `warp` mounted beside
# the `selvage` the tree returns is one `selvage` too. A shallower kind holding a deeper one holds the
# same construction: `loom`, which inherits nothing, defaults its `bolt` to the tree's `cloth`.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  trail = l: { config.trail = l; };
  t = genSchema.evalSchema { } [
    (
      { config, ... }:
      {
        config.schema.loom.options.bolt = genMerge.mkOption {
          type = genMerge.types.raw;
          default = config.schema.cloth;
        };
      }
    )
    {
      config.schema = {
        fibre.options.trail = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; };
        selvage = {
          inherits = [ "fibre" ];
          options.ends = genMerge.mkOption {
            type = genMerge.types.int;
            default = 0;
          };
        }
        // trail [ "selvage" ];
        warp = {
          inherits = [ "selvage" ];
        }
        // trail [ "warp" ];
        cloth = {
          inherits = [
            "selvage"
            "warp"
          ];
        }
        // trail [ "cloth" ];
      };
    }
  ];
  count = n: l: builtins.length (builtins.filter (x: x == n) l);
  viaGen = (genMerge.evalModuleTree { } [ t.cloth ]).config.trail;
  viaNixpkgs = (lib.evalModules { modules = [ t.cloth ]; }).config.trail;
  beside =
    (genMerge.evalModuleTree { } [
      t.warp
      t.selvage
    ]).config.trail;
  once = l: count "selvage" l == 1 && count "warp" l == 1;
  bolt = t.loom.options.bolt.default;
  boltBeside =
    (genMerge.evalModuleTree { } [
      t.cloth
      bolt
    ]).config.trail;
in
{
  construct = [ "an-evalschema-mixed-depth-diamond-composes-once" ];
  check = asserts (
    once viaGen
    && once viaNixpkgs
    && count "selvage" beside == 1
    && genSchema.kindEq bolt t.cloth
    && count "selvage" boltBeside == 1
  );
}
