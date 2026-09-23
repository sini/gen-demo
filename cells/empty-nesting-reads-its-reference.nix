# `empty-nesting-reads-its-reference` — C42, den-hoag-9f4bn. A nesting option whose every definition
# was discharged reads what nixpkgs reads. A `submodule` defined only under `mkIf false` is its
# module set over no definitions, so `weft` reads its default `plain`, where it used to abort
# uncatchably. A strict `attrsOf` drops the discharged element, so `bolts` has no `linen`. The
# control, with the condition true, reads `twill` at both.
#
# C42 — den-hoag-9f4bn: a nesting option whose every definition was discharged
# reads what its nixpkgs reference reads. A `submodule` option defined only under
# `mkIf false` yields the module set evaluated over no definitions (nixpkgs
# `submoduleWith`'s `base.config`), so `weft` reads its default, where it used to
# abort uncatchably; a strict `attrsOf` DROPS an element whose every definition was
# discharged, where it used to keep the key. With the condition true both read the
# definition.
{ asserts, genMerge }:
{
  construct = [ "C42" ];
  check = asserts (
    let
      selvage = genMerge.types.submodule {
        options.weft = genMerge.mkOption {
          type = genMerge.types.str;
          default = "plain";
        };
      };
      read =
        on:
        (genMerge.evalModuleTree {
          modules = [
            {
              options.selvage = genMerge.mkOption { type = selvage; };
              options.bolts = genMerge.mkOption { type = genMerge.types.attrsOf selvage; };
            }
            {
              selvage = genMerge.mkIf on { weft = "twill"; };
              bolts.linen = genMerge.mkIf on { weft = "twill"; };
            }
          ];
        }).config;
    in
    (read false).selvage.weft == "plain"
    && builtins.attrNames (read false).bolts == [ ]
    && (read true).selvage.weft == "twill"
    && (read true).bolts.linen.weft == "twill"
  );
}
