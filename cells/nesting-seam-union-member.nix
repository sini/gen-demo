# `nesting-seam-union-member` — C73, den-hoag-moduletree-union-member-refused-f8mgj. The tree type
# `(evalModuleTree …).type` is a union member in gen-merge's own eval: `either spoolTree str` takes a
# function def as the tree, `spool = "sateen"`, and a string def as the string, `"selvedge"`, as
# nixpkgs' `either` over its own `(evalModules …).type` does. Both were refused, the union reading
# the tree's `check`, which refuses because the tree is not an option type.
{ asserts, genMerge }:
{
  construct = [ "C73" ];
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
      member = genMerge.types.either spoolTree genMerge.types.str;
    in
    (at member ({ ... }: { spool = "sateen"; })).spool == "sateen" && at member "selvedge" == "selvedge"
  );
}
