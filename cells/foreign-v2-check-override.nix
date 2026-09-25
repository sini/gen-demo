# `foreign-v2-check-override` — C61, den-hoag-v2-check-override-accepted-ku5dt. A nixpkgs v2 type
# (its `merge` carries `v2`) given an ad-hoc `// { check = …; }` is refused, as nixpkgs refuses it; on
# a submodule-bearing one, where nixpkgs erases the override without a word, it is refused too. The
# `addCheck` spelling of the same check reads `sateen`, so a fold refusing everything cannot pass;
# the messages are `refusals` rows 79/80's.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "C61" ];
  check = asserts (
    let
      read =
        type: v:
        (genMerge.evalModuleTree {
          modules = [
            { options.spool = genMerge.mkOption { inherit type; }; }
            { spool = v; }
          ];
        }).config.spool;
      refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
      bolt = lib.types.submodule { options.warp = lib.mkOption { type = lib.types.str; }; };
    in
    refused (lib.types.attrsOf lib.types.str // { check = builtins.isAttrs; }) { warp = "sateen"; }
    && refused (bolt // { check = builtins.isAttrs; }) { warp = "sateen"; }
    &&
      (read (lib.types.addCheck (lib.types.attrsOf lib.types.str) builtins.isAttrs) { warp = "sateen"; })
      .warp == "sateen"
    && (read bolt { warp = "sateen"; }).warp == "sateen"
  );
}
