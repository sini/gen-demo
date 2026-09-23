# `union-member-refuses-by-name` — C48, den-hoag-cyiuz. gen-types' combinators refuse a member that
# is not a checker by name: a union over C39's `keyed` submodule and `str`, given `{ key = "sateen";
# }`, is refused catchably, where it aborted with `attribute 'verify' missing`. The checker-only
# `union [ str int ]` given `"sateen"` answers it, so a union refusing everything cannot pass. The
# message is `refusals` row 43's.
#
# C48 — den-hoag-cyiuz: a gen-types combinator over a member that is not a
# checker refuses by name. A gen-merge `submodule` carries `admits` and no `verify`,
# so `union [ keyed str ]` aborted uncatchably (`attribute 'verify' missing`) on its
# first read; it is now refused catchably, and the checker-only `union [ str int ]`
# beside it still answers, so a union refusing everything cannot pass. The message
# is `refusals` row 43's.
{ asserts, genMerge }:
{
  construct = [ "C48" ];
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
      keyed = genMerge.types.submodule {
        options.key = genMerge.mkOption {
          type = genMerge.types.str;
          default = "none";
        };
      };
    in
    !(builtins.tryEval (
      builtins.deepSeq (at (genMerge.types.union [
        keyed
        genMerge.types.str
      ]) { key = "sateen"; }) true
    )).success
    &&
      at (genMerge.types.union [
        genMerge.types.str
        genMerge.types.int
      ]) "sateen" == "sateen"
  );
}
