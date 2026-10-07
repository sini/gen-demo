# ── A KIND ITS OWN INSTANCES' NAMES DECIDE COMPOSES ON BOTH CONSTRUCTS (den-hoag-2vo1m) ──
# THE KNOB: a kind read off the tree that declares the construct (`config.schema.lappet`) can be
# defined by that tree's own config. Two shapes compose, and on the registry and on its
# `mkInstanceType` sibling alike: a separate value-plane option decides the kind, or the
# construct's own instance NAMES do (`config.lappets ? l1`). The registry's name set is its
# definitions', as the sibling's is, so answering `? l1` reads no kind. The third shape, an instance
# VALUE deciding its own kind, aborts uncatchably on both and is gen-schema's enumerated exception
# (`ci/tests-error.nix`, `knob-instance-value-decides-its-kind`); an uncatchable abort cannot be a
# `checks` cell, so it is pinned there and not here.
{ genMerge, inputs }:
let
  S = inputs.gen.lib.substrate.schema;
  M = genMerge;
  nap =
    d:
    M.mkOption {
      type = M.types.str;
      default = d;
    };
  kindDecl = {
    options.schema = S.mkSchemaOption { };
    config.schema.lappet.options.nap = M.mkOption { type = M.types.str; };
  };
  inst.config.lappets.l1.nap = "plush";
  registry = { config, ... }: { options.lappets = S.mkInstanceRegistry { } config.schema.lappet; };
  sibling =
    { config, ... }:
    {
      options.lappets = M.mkOption {
        type = M.types.attrsOf (S.mkInstanceType { } config.schema.lappet);
        default = { };
      };
    };
  valuePlane = on: { config, ... }: {
    options.lappetKnob = M.mkOption {
      type = M.types.bool;
      default = on;
    };
    config.schema.lappet = if config.lappetKnob then { options.weft = nap "woven"; } else { };
  };
  byNames = { config, ... }: {
    config.schema.lappet = if config.lappets ? l1 then { options.weft = nap "woven"; } else { };
  };
  read =
    construct: extra:
    let
      l =
        (M.evalModuleTree { } (
          [
            kindDecl
            construct
            inst
          ]
          ++ extra
        )).config.lappets.l1;
    in
    {
      inherit (l) nap;
      weft = l.weft or null;
    };
in
{
  lappetKnob = {
    registry = {
      off = read registry [ (valuePlane false) ];
      on = read registry [ (valuePlane true) ];
      byNames = read registry [ byNames ];
    };
    sibling = {
      off = read sibling [ (valuePlane false) ];
      on = read sibling [ (valuePlane true) ];
      byNames = read sibling [ byNames ];
    };
  };
}
