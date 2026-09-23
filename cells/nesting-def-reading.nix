# `nesting-def-reading` — C39, den-hoag-za4hp. gen-merge's two nesting types read a definition the
# way their nixpkgs references do. The tree type `(evalModuleTree …).type` reads every def as a
# module, so a function def yields `spool = "sateen"`, where it used to abort uncatchably;
# `types.submodule` reads an attrset def as config, so an option it declares as `key` takes
# `sateen`, where the key was dropped as module identity and read the default.
#
# C39 — den-hoag-za4hp: each nesting seam reads a definition the way its
# nixpkgs reference does. The tree type `(evalModuleTree …).type` reads every def
# as a MODULE, as `(lib.evalModules …).type`: a FUNCTION def yields its value, where
# it used to abort uncatchably. `types.submodule` reads an ATTRSET def as CONFIG, as
# `lib.types.submodule`: an option the submodule declares as `key` takes the def's
# value, where it used to be dropped as module identity and read the default.
{ asserts, genMerge }:
{
  construct = [ "C39" ];
  check = asserts (
    let
      at =
        type: def:
        (genMerge.evalModuleTree {
          modules = [
            { options.seam = genMerge.mkOption { inherit type; }; }
            { config.seam = def; }
          ];
        }).config.seam;
      spoolTree =
        (genMerge.evalModuleTree {
          modules = [
            {
              options.spool = genMerge.mkOption {
                type = genMerge.types.str;
                default = "none";
              };
            }
          ];
        }).type;
      keyed = genMerge.types.submodule {
        options.key = genMerge.mkOption {
          type = genMerge.types.str;
          default = "none";
        };
      };
    in
    (at spoolTree ({ ... }: { spool = "sateen"; })).spool == "sateen"
    && (at keyed { key = "sateen"; }).key == "sateen"
  );
}
