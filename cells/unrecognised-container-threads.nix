# `unrecognised-container-threads` — C119. nixpkgs' `uniq` is a container outside the six gen-merge
# re-homes as its own. Over a gen `either` whose member is a nested tree (`spool`'s module tree), it
# is rebuilt through its own `substSubModules`, so the tree is a node of the one evaluation and the
# value is nixpkgs': a module definition reads `sateen` through the tree and a string definition reads
# `selvedge`. gen-merge used to refuse both by name, as a container that cannot thread the evaluation
# to a nested tree. nixpkgs' `coercedTo` holds the same member the same way: its check calls the
# union's, which reads the tree's `check`, its module-value domain (den-hoag-f8mgj arm Q), where
# gen-merge used to keep the import refusal. The control is nixpkgs' `nullOr` over the same member,
# one of the six, which answers the same two definitions either way.
{
  asserts,
  genMerge,
  lib,
}:
let
  read =
    type: v:
    (genMerge.evalModuleTree {
      modules = [
        { options.seam = genMerge.mkOption { inherit type; }; }
        { seam = v; }
      ];
    }).config.seam;
  spool =
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
  answers =
    holder:
    let
      type = holder (genMerge.types.either spool genMerge.types.str);
    in
    (read type ({ ... }: { spool = "sateen"; })).spool == "sateen"
    && read type "selvedge" == "selvedge";
in
{
  construct = [ "C119" ];
  check = asserts (
    answers lib.types.uniq
    && answers (lib.types.coercedTo lib.types.bool (_: null))
    && answers lib.types.nullOr
  );
}
