# `import-door-over-a-registry-knot` — den-hoag-6foy1. A bobbin's `weave` is a submodule whose module set
# declares one option per bobbin, named by each bobbin's own `name`: it reads back into the registry
# being built. Placed through `mkOptionType`, once and twice, the door's question (is this record a `//`
# copy of its completion?) is asked of each field the door reads, never of the fields the module set
# itself decides, so the registry evaluates on every evaluator and serves what the bare submodule serves.
# A copy departing at a field the door reads still loses its identity there.
{
  asserts,
  genSchema,
  genMerge,
}:
let
  T = genMerge.types;
  weave =
    bobbins:
    T.submodule {
      imports = map (b: {
        options."pick-${b.name}" = genMerge.mkOption {
          type = T.str;
          default = b.spool;
        };
      }) (builtins.attrValues bobbins);
    };
  served =
    door:
    let
      kinds = genSchema.evalSchema { } [
        {
          config.schema.bobbin = {
            options.spool = genMerge.mkOption { type = T.str; };
            options.weave = genMerge.mkOption {
              type = door (weave loom.config.bobbins);
              default = { };
            };
          };
        }
      ];
      loom = genMerge.evalModuleTree { } [
        {
          options.bobbins = genSchema.mkInstanceRegistry { } kinds.bobbin;
          config.bobbins.damask.spool = "linen";
          config.bobbins.faille.spool = "pewter";
        }
      ];
    in
    {
      inherit (loom.config.bobbins.damask) spool weave;
    };
  bare = served (s: s);
  copied = genMerge.mkOptionType (
    T.int
    // {
      mergeDefs = _: { value = 0; };
    }
  );
in
{
  construct = [ "an-import-door-over-a-registry-knot-serves" ];
  check = asserts (
    served genMerge.mkOptionType == bare
    && served (s: genMerge.mkOptionType (genMerge.mkOptionType s)) == bare
    &&
      bare.weave == {
        pick-damask = "linen";
        pick-faille = "pewter";
      }
    && !(builtins.tryEval (genMerge.types.idOf copied)).success
  );
}
