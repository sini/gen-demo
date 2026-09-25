# `mkoptiontype-default-merge` — C62, den-hoag-mkoptiontype-default-merge-ojxeh. A check-only
# `mkOptionType` (it states `name` and no fold) merges by nixpkgs' constructor default,
# `merge ? mergeDefaultOption`: `heddle`, defined `[ "warp" ]` and `[ "weft" ]` in two files, reads
# `[ "weft" "warp" ]`, as nixpkgs' `lib.evalModules` reads it, where gen-merge used to refuse the pair
# as unequal. Beside it, the same option given `1` and `2` is still refused catchably, so a fold that
# accepts everything cannot pass; and given `{ a = 1; }` and `{ a = 2; }` it is refused where nixpkgs
# keeps the FIRST file's value, `{ a = 1; }`, without a word (the parity criterion's carve-out,
# owner 2026-09-25).
{ asserts, genMerge }:
let
  thread = genMerge.mkOptionType {
    name = "thread";
    check = v: builtins.isList v || builtins.isInt v || builtins.isAttrs v;
  };
  read =
    a: b:
    (genMerge.evalModuleTree {
      modules = [
        { options.heddle = genMerge.mkOption { type = thread; }; }
        {
          _file = "/demo/warp.nix";
          heddle = a;
        }
        {
          _file = "/demo/weft.nix";
          heddle = b;
        }
      ];
    }).config.heddle;
  attempt = v: builtins.tryEval (builtins.deepSeq v v);
  refused = v: !(attempt v).success;
  combined = attempt (read [ "warp" ] [ "weft" ]);
in
{
  construct = [ "C62" ];
  check = asserts (
    combined.success
    &&
      combined.value == [
        "weft"
        "warp"
      ]
    && refused (read 1 2)
    && refused (read { a = 1; } { a = 2; })
  );
}
