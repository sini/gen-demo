# `internal-tree-reports-its-orphan` — C30, den-hoag-1ksl. An option typed with gen-merge's own
# nesting seam (another `evalModuleTree` call's `.type`, not `t.submodule`), both levels at `check =
# false`, receives a key its inner tree does not declare. The outer `.undeclared` names it at its
# full path and `.config` is exactly the declared part; before, the def vanished at exit 0. The same
# key at the tree's own top level is the control that the report was already live there.
#
# C30 — an internal nested tree reports its own orphan (ADR-0025 item 1,
# den-hoag-1ksl). `hem` is typed with gen-merge's own nesting seam — another
# `evalModuleTree` call's `.type`, not `t.submodule` — and both levels run with
# `check = false`, the regime where the nested key used to vanish at exit 0 with
# `.config` silently smaller. The outer `.undeclared` now names `fray` at its
# full path, and `.config` is exactly the declared part. The control is the SAME
# key at the tree's own top level, which the channel already covered: without it
# the cell could pass on a report that was never about the nested seam.
{ asserts, genMerge }:
{
  construct = [ "C30" ];
  check = asserts (
    let
      hemTree =
        (genMerge.evalModuleTree {
          check = false;
          modules = [
            {
              options.selvedge = genMerge.mkOption {
                type = genMerge.types.str;
                default = "raw";
              };
            }
          ];
        }).type;
      nested = genMerge.evalModuleTree {
        check = false;
        modules = [
          {
            options.hem = genMerge.mkOption {
              type = hemTree;
              default = { };
            };
          }
          {
            _file = "c30";
            config.hem = {
              selvedge = "pinked";
              fray = "loose";
            };
          }
        ];
      };
      topLevel = genMerge.evalModuleTree {
        check = false;
        modules = [
          {
            options.selvedge = genMerge.mkOption {
              type = genMerge.types.str;
              default = "raw";
            };
          }
          {
            _file = "c30";
            config.fray = "loose";
          }
        ];
      };
    in
    map (u: u.path) nested.undeclared == [
      [
        "hem"
        "fray"
      ]
    ]
    && map (u: u.file) nested.undeclared == [ "c30" ]
    &&
      nested.config.hem == {
        selvedge = "pinked";
      }
    && map (u: u.path) topLevel.undeclared == [ [ "fray" ] ]
  );
}
