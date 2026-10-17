# `gen-submodules-in-an-attr-list-name-their-declaring-file` — den-hoag-j2ryo, the sibling of
# `gen-nesting-types-name-their-declaring-file` under nixpkgs' `attrListOf`. A loom declared in `heddle.nix` states a
# `bolts` option of nixpkgs' `attrListOf` over gen's `submodule`, whose module states no `_file` and reads its own
# `options` argument (`seen = options.warp.declarations`). An entry's `seen`, read through gen-merge's engine, must
# equal the twin construction over nixpkgs' types and `evalModules`, which names `heddle.nix`: the file of the
# declaration carrying the type. gen-merge named `<unknown-file>`, its walk not counting `attrListOf` among the
# containers that forward their element's module set.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom =
    L:
    let
      T = L.types;
      warp =
        { options, ... }:
        {
          options.warp = L.mkOption {
            type = T.int;
            default = 3;
          };
          options.seen = L.mkOption { default = options.warp.declarations; };
        };
    in
    [
      {
        _file = "heddle.nix";
        options.bolts = L.mkOption {
          type = lib.types.attrListOf (T.submodule warp);
          default = [ ];
        };
      }
      {
        _file = "treadle.nix";
        config.bolts = [ { k = { }; } ];
      }
    ];
  read = ev: (builtins.head ev.config.bolts).k.seen;
  gen = read (genMerge.evalModuleTree { } (loom genMerge));
  ref = read (lib.evalModules { modules = loom lib; });
in
{
  construct = [ "gen-nesting-types-name-their-declaring-file-as-nixpkgs-does" ];
  check = asserts (ref == [ "heddle.nix" ] && gen == ref);
}
