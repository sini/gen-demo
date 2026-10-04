# `kind-value-swap-refused` — C129, den-hoag-1a4f6. A kind value is a completed record whose mark is a
# claim about that value, and `//` copies the mark with every slot it does not override. The kind
# carries a completion stamp, so `grommet // { options = { }; }` is refused where the mark decides:
# compared with `grommet` (in either order, and carried through `types.anything`), inherited by a
# same-tree kind (the NAME path, decided by `kindEq`), inherited from another tree (the VALUE path), and
# selected by `sel.kind`. Each refusal has an admitted twin with the `//` removed or content-equal:
# `grommet` against itself and through `anything`, `grommet // { }`, and both `inherits` paths composing
# `eyelets`. Red when the copy is admitted at any door, or when an honest twin is refused. The refusal
# MESSAGES are `refusals` row 135.
{
  asserts,
  genMerge,
  genSelect,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  inherit (schema) kindEq;
  intOpt = genMerge.mkOption { type = genMerge.types.int; };
  tree =
    modules:
    (genMerge.evalModuleTree { } ([ { options.schema = schema.mkSchemaOption { }; } ] ++ modules))
    .config.schema;
  grommet =
    (tree [
      {
        config.schema.grommet.options.eyelets = genMerge.mkOption {
          type = genMerge.types.int;
          default = 8;
        };
      }
    ]).grommet;
  swapped = grommet // {
    options = { };
  };
  viaAnything =
    v:
    (genMerge.evalModuleTree { } [
      { options.v = genMerge.mkOption { type = genMerge.types.anything; }; }
      { config.v = v; }
    ]).config.v;
  # `tab` inherits the tree's own `grommet`, as `f` hands it over
  sameTreeTab =
    f:
    (tree [
      { config.schema.grommet.options.eyelets = intOpt; }
      (
        { config, ... }:
        {
          config.schema.tab = {
            inherits = [ (f config.schema.grommet) ];
            options.loop = intOpt;
          };
        }
      )
    ]).tab;
  # `tab` inherits a `grommet` from another tree
  foreignTab =
    parent:
    (tree [
      {
        config.schema.tab = {
          inherits = [ parent ];
          options.loop = intOpt;
        };
      }
    ]).tab;
  opts = k: builtins.attrNames k.options;
  refused = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
in
{
  construct = [ "C129" ];
  check = asserts (
    refused (kindEq grommet swapped)
    && refused (kindEq swapped grommet)
    && refused (kindEq grommet (viaAnything swapped))
    && refused (opts (sameTreeTab (g: g // { options = { }; })))
    && refused (opts (foreignTab swapped))
    && refused (genSelect.selectorEq (genSelect.kind grommet) (genSelect.kind swapped))
    && kindEq grommet grommet
    && kindEq grommet (viaAnything grommet)
    && kindEq grommet (grommet // { })
    && genSelect.selectorEq (genSelect.kind grommet) (genSelect.kind grommet)
    &&
      opts (sameTreeTab (g: g)) == [
        "eyelets"
        "loop"
      ]
    &&
      opts (foreignTab grommet) == [
        "eyelets"
        "loop"
      ]
  );
}
