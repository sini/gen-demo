# `module-decl-shapes` — C148, den-hoag-module-decl-shapes-parity-wv300. An `options._module` typed
# `submodule` takes every `_module.<x>` the engine does not own and still serves `_module.args`, and
# an `apply` on `args` declared inside it maps the merged set; an `apply` on a nested child's
# `_module.args` maps the set holding its position's `name`, so the `name` its modules read is the
# applied one, under `attrsOf` of a gen module tree and of `types.submodule`. Each must equal the same
# construction in nixpkgs' own `lib.evalModules`, where gen-merge refused the leaf as a single option
# and read the position over the `apply`. A child with no `apply` reads its position, the control.
# The planted halves (an owned key re-declared with another type, or as a group) are `refusals`
# row 137.
{
  asserts,
  genMerge,
  lib,
}:
let
  # `eval`, `mkOption` and `T` are the evaluating module system's.
  leaf =
    eval: mkOption: T: extra:
    (eval {
      modules = [
        {
          options._module = mkOption {
            type = T.submodule {
              options = {
                weft = mkOption { default = 1; };
              }
              // extra mkOption;
            };
            default = { };
          };
          config._module.weft = 2;
          config._module.args.sateen = "P";
        }
        (
          { config, sateen, ... }:
          {
            options.seam = mkOption { };
            config.seam = [
              config._module.weft
              sateen
            ];
          }
        )
      ];
    }).config.seam;
  mapsArgs = mkOption: { args = mkOption { apply = a: a // { sateen = "Q"; }; }; };
  # A child under `attrsOf`, reading `name`, with or without an `apply` that renames it; `tree` makes
  # the child a module tree (an evaluation's `.type`), or else `T.submodule`.
  warp =
    eval: mkOption: T: tree: renamed:
    let
      mods = [
        ({ name, ... }: { options.weft = mkOption { default = name; }; })
      ]
      ++ (
        if renamed then
          [ { options._module.args = mkOption { apply = a: a // { name = "Q"; }; }; } ]
        else
          [ ]
      );
      child = if tree then (eval { modules = mods; }).type else T.submodule { imports = mods; };
    in
    (eval {
      modules = [
        { options.seam = mkOption { type = T.attrsOf child; }; }
        { seam.warp = { }; }
      ];
    }).config.seam.warp.weft;
  native = {
    leaf = leaf genMerge.evalModuleTree genMerge.mkOption genMerge.types;
    warp = warp genMerge.evalModuleTree genMerge.mkOption genMerge.types;
  };
  ref = {
    leaf = leaf lib.evalModules lib.mkOption lib.types;
    warp = warp lib.evalModules lib.mkOption lib.types;
  };
in
{
  construct = [ "C148" ];
  check = asserts (
    ref.leaf (_: { }) == [
      2
      "P"
    ]
    && native.leaf (_: { }) == ref.leaf (_: { })
    &&
      ref.leaf mapsArgs == [
        2
        "Q"
      ]
    && native.leaf mapsArgs == ref.leaf mapsArgs
    && ref.warp true true == "Q"
    && native.warp true true == ref.warp true true
    && native.warp false true == ref.warp false true
    && ref.warp true false == "warp"
    && native.warp true false == ref.warp true false
    && native.warp false false == ref.warp false false
  );
}
