# `schema-import-reads-the-instantiating-lib` — den-hoag-61r97 (owner-ruled S4). gen-merge's `lib` is an
# instantiation parameter, as nixpkgs' `lib/modules.nix` is `{ lib }:`. Built with nixpkgs' lib, a module
# of den's schema-import form, `{ lib, ... }:` declaring its options through `lib`, reads that lib at the
# root, under `submodule`, under `attrsOf (submodule …)`, through an extension and when nixpkgs' own
# `evalModules` mounts the gen `submodule`, exactly as under nixpkgs' `lib.evalModules`; a caller's
# `specialArgs.lib` wins at the root and does not reach the submodule, and `_module.args.lib` is
# shadowed, as there. The published engine, built with none, still refuses the read by name.
# The engine is the hub's lib door, `inputs.gen.lib.instantiate { inherit lib; }`, reached through the
# published surface: its gen-schema registry, its `compose` and the standalone entry's door
# (`import <gen> { inherit lib; }`) read the same lib.
{
  asserts,
  inputs,
  lib,
  genMerge,
}:
let
  door = inputs.gen.lib.instantiate { inherit lib; };
  built = door.modules.merge;
  roster = door.mkGenLibs { };
  tag =
    l:
    l.marker or (
      if l ? evalModuleTree then
        "gen"
      else if l ? evalModules then
        "instance"
      else
        "other"
    );
  schemaImport =
    { lib, ... }:
    {
      options.weft = lib.mkOption {
        type = lib.types.str;
        default = tag lib;
      };
    };
  eval =
    E: r:
    if E ? evalModuleTree then
      E.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
    else
      E.evalModules r;
  sub = E: {
    options.loom = E.mkOption {
      type = E.types.submodule [ schemaImport ];
      default = { };
    };
  };
  at =
    E: specialArgs: modules:
    (eval E { inherit specialArgs modules; }).config;
  reads = E: {
    root = (at E { } [ schemaImport ]).weft;
    loom = (at E { } [ (sub E) ]).loom.weft;
    bolt =
      (at E { } [
        { options.bolt = E.mkOption { type = E.types.attrsOf (E.types.submodule [ schemaImport ]); }; }
        { bolt.warp = { }; }
      ]).bolt.warp.weft;
    extended = ((eval E { modules = [ ]; }).extendModules { modules = [ schemaImport ]; }).config.weft;
    mounted = (lib.evalModules { modules = [ (sub E) ]; }).config.loom.weft;
    callerAtRoot =
      (at E {
        lib = lib // {
          marker = "caller";
        };
      } [ schemaImport ]).weft;
    callerNotInLoom =
      (at E {
        lib = lib // {
          marker = "caller";
        };
      } [ (sub E) ]).loom.weft;
    moduleArgsShadowed =
      (at E { } [
        {
          _module.args.lib = lib // {
            marker = "module-args";
          };
        }
        { options.x = E.mkOption { type = E.types.str; }; }
        ({ lib, ... }: { x = tag lib; })
      ]).x;
  };
  # den #766's shape through the door's gen-schema: an instance registry whose kind module reads `lib`
  registryRead =
    R:
    let
      s = R.schema.evalSchema { } [
        { config.schema.node.options.addr = R.merge.mkOption { type = R.merge.types.str; }; }
      ];
    in
    (R.merge.evalModuleTree { } [
      {
        options.nodes = R.schema.mkInstanceRegistry { extraModules = [ schemaImport ]; } s.node;
        config.nodes.n1.addr = "10.0.0.1";
      }
    ]).config.nodes.n1.weft;
in
{
  construct = [ "a-schema-import-module-reads-the-lib-its-engine-is-built-with-3" ];
  check = asserts (
    reads built == reads lib
    && registryRead roster == "instance"
    && registryRead (import inputs.gen.outPath { inherit lib; }) == "instance"
    && (door.compose { modules = [ schemaImport ]; }).values.weft == "instance"
    && (reads lib).loom == "instance"
    && !(builtins.tryEval (at genMerge { } [ (sub genMerge) ]).loom.weft).success
  );
}
