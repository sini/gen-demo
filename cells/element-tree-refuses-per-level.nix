# `element-tree-refuses-per-level` — C44, den-hoag-0s6zi. A `check = false` nested tree used as an
# `attrsOf` element has no undeclared report, and a key its level does not declare used to vanish at
# exit 0. It is now refused by name when the level holding it is read, one level down as well, while
# an unread level decides nothing; the same tree typed bare still reports the key rather than
# refusing it. The message is `refusals` row 37's.
#
# C44 — a nested tree used as a container element refuses, level by level, the
# key it cannot report (ADR-0025 item 1, den-hoag-0s6zi). C30's tree typed BARE
# reports its orphan; the same seam as an `attrsOf` ELEMENT has no report channel,
# and the key used to vanish at exit 0. It is refused by name when the level that
# holds it is read, and a level not read decides nothing, as nixpkgs refuses per
# level. The bare arm (5) is the control that the report channel is untouched; the
# message is `refusals` row 37's.
{ asserts, genMerge }:
{
  construct = [ "C44" ];
  check = asserts (
    let
      liningTree =
        (genMerge.evalModuleTree {
          check = false;
          modules = [
            {
              options.weave = genMerge.mkOption {
                type = genMerge.types.str;
                default = "plain";
              };
            }
          ];
        }).type;
      pocketTree =
        (genMerge.evalModuleTree {
          check = false;
          modules = [
            {
              options.selvedge = genMerge.mkOption {
                type = genMerge.types.str;
                default = "raw";
              };
              options.lining = genMerge.mkOption { type = liningTree; };
            }
          ];
        }).type;
      pockets =
        def:
        genMerge.evalModuleTree {
          check = false;
          modules = [
            { options.pockets = genMerge.mkOption { type = genMerge.types.attrsOf pocketTree; }; }
            {
              _file = "c44";
              config.pockets = def;
            }
          ];
        };
      bare = genMerge.evalModuleTree {
        check = false;
        modules = [
          { options.pocket = genMerge.mkOption { type = pocketTree; }; }
          {
            _file = "c44";
            config.pocket = {
              selvedge = "pinked";
              fray = "loose";
            };
          }
        ];
      };
      refuses = e: !(builtins.tryEval (builtins.deepSeq e null)).success;
    in
    # (1) clean elements are values
    (pockets { welt.selvedge = "pinked"; }).config.pockets == {
      welt = {
        selvedge = "pinked";
        lining.weave = "plain";
      };
    }
    # (2) a throwing leaf nested inside an element, not read, stays unforced
    &&
      (pockets {
        welt = {
          selvedge = "pinked";
          lining = throw "unread";
        };
      }).config.pockets.welt.selvedge == "pinked"
    # (3) an undeclared key inside an element is refused, not dropped ...
    &&
      refuses
        (pockets {
          welt = {
            selvedge = "pinked";
            fray = "loose";
          };
        }).config.pockets
    # (4) ... one level down, when ITS level is read, while the element's own level is a value
    &&
      refuses
        (pockets {
          welt.lining = {
            weave = "twill";
            fray = "loose";
          };
        }).config.pockets.welt.lining
    &&
      (pockets {
        welt.lining = {
          weave = "twill";
          fray = "loose";
        };
      }).config.pockets.welt.selvedge == "raw"
    # (5) CONTROL: the same tree typed bare still REPORTS rather than refuses
    &&
      map (u: u.path) bare.undeclared == [
        [
          "pocket"
          "fray"
        ]
      ]
    &&
      bare.config.pocket == {
        selvedge = "pinked";
        lining.weave = "plain";
      }
  );
}
