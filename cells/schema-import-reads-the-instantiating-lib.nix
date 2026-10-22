# `schema-import-reads-the-instantiating-lib` — den-hoag-61r97 (owner-ruled S4). gen-merge's `lib` is an
# instantiation parameter, as nixpkgs' `lib/modules.nix` is `{ lib }:`. Built with nixpkgs' lib, a module
# of den's schema-import form, `{ lib, ... }:` declaring its options through `lib`, reads that lib at the
# root, under `submodule`, under `attrsOf (submodule …)`, through an extension and when nixpkgs' own
# `evalModules` mounts the gen `submodule`, exactly as under nixpkgs' `lib.evalModules`; a caller's
# `specialArgs.lib` wins at the root and does not reach the submodule, and `_module.args.lib` is
# shadowed, as there. The published engine, built with none, still refuses the read by name.
{
  asserts,
  inputs,
  lib,
  genMerge,
}:
let
  hub = inputs.gen.inputs;
  built = import "${hub.gen-merge}/lib" {
    prelude = hub.gen-prelude.lib;
    types = hub.gen-types.lib;
    memo = hub.gen-memo.lib;
    scope = hub.gen-scope.lib;
    inherit lib;
  };
  tag = l: l.marker or (if l ? evalModuleTree then "gen" else if l ? evalModules then "instance" else "other");
  schemaImport =
    { lib, ... }:
    {
      options.weft = lib.mkOption {
        type = lib.types.str;
        default = tag lib;
      };
    };
  eval = E: r: if E ? evalModuleTree then E.evalModuleTree (removeAttrs r [ "modules" ]) r.modules else E.evalModules r;
  sub = E: {
    options.loom = E.mkOption {
      type = E.types.submodule [ schemaImport ];
      default = { };
    };
  };
  at = E: specialArgs: modules: (eval E { inherit specialArgs modules; }).config;
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
    callerAtRoot = (at E { lib = lib // { marker = "caller"; }; } [ schemaImport ]).weft;
    callerNotInLoom = (at E { lib = lib // { marker = "caller"; }; } [ (sub E) ]).loom.weft;
    moduleArgsShadowed =
      (at E { } [
        { _module.args.lib = lib // { marker = "module-args"; }; }
        { options.x = E.mkOption { type = E.types.str; }; }
        ({ lib, ... }: { x = tag lib; })
      ]).x;
  };
in
{
  construct = [ "a-schema-import-module-reads-the-lib-its-engine-is-built-with-3" ];
  check = asserts (
    reads built == reads lib
    && (reads lib).loom == "instance"
    && !(builtins.tryEval (at genMerge { } [ (sub genMerge) ]).loom.weft).success
  );
}
