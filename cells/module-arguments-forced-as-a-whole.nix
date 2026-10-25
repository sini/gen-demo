# `module-arguments-forced-as-a-whole` — den-hoag-b44rx. A loom forces its whole `_module.args` set, `mkForce
# { shuttle = 1; }`, at the top in `treadle.nix` and in the module of a gen `submodule` option `bolt`, beside a
# reader of `shuttle`. Each evaluation's `config._module.args` keys, the `shuttle` read and the `name` a module
# finds through `config._module.args` must equal the same construction over nixpkgs' types and `evalModules`, which
# serves the forced set alone: no `extendModules`, `moduleType` or position `name`. A module reading `name` in the
# forced `bolt` is refused by name and catchably, where nixpkgs aborts on `attribute 'name' missing`. gen-merge
# kept serving the engine's own arguments beside the forced set, and served `bolt`'s position name.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom =
    L:
    let
      warp = {
        _file = "warp.nix";
        _module.args = L.mkForce { shuttle = 1; };
        imports = [
          (
            { config, shuttle, ... }:
            {
              options.keys = L.mkOption { default = builtins.attrNames config._module.args; };
              options.seen = L.mkOption { default = shuttle; };
              options.named = L.mkOption { default = config._module.args.name or "<none>"; };
            }
          )
        ];
      };
    in
    [
      warp
      {
        _file = "heddle.nix";
        options.bolt = L.mkOption {
          type = L.types.submodule warp;
          default = { };
        };
      }
    ];
  read = ev: {
    top = { inherit (ev.config) keys seen named; };
    bolt = { inherit (ev.config.bolt) keys seen named; };
  };
  gen = read (genMerge.evalModuleTree { } (loom genMerge));
  ref = read (lib.evalModules { modules = loom lib; });
  # the forced `bolt` read through a module's `name` formal: refused by name in gen (nixpkgs aborts); the same
  # module over an unforced set serves the position's name
  genName =
    args:
    (genMerge.evalModuleTree { } [
      {
        options.bolt = genMerge.mkOption {
          type = genMerge.types.submodule (
            { name, ... }:
            {
              config._module.args = args;
              options.n = genMerge.mkOption { default = name; };
            }
          );
          default = { };
        };
      }
    ]).config.bolt.n;
in
{
  construct = [ "a-module-arguments-set-forced-as-a-whole-serves-only-what-it-forces" ];
  check = asserts (
    ref == {
      top = {
        keys = [ "shuttle" ];
        seen = 1;
        named = "<none>";
      };
      bolt = {
        keys = [ "shuttle" ];
        seen = 1;
        named = "<none>";
      };
    }
    && gen == ref
    && genName { shuttle = 1; } == "bolt"
    && !(builtins.tryEval (genName (genMerge.mkForce { shuttle = 1; }))).success
  );
}
