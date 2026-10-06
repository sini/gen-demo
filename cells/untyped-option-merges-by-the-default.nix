# `untyped-option-merges-by-the-default` — C193, den-hoag-yu8sa. An option declared with no `type`
# merges as nixpkgs merges it, by `types.unspecified`, the constructor default: `reed`, defined `"warp"`
# in two files, reads `"warpwarp"`, as nixpkgs' `lib.evalModules` reads it, where gen-merge used to
# serve `"warp"` without a word; `{ warp = 1; }` beside `{ weft = 2; }` reads their union, where the
# pair was refused as unequal. Beside them, the same option given `1` and `2` is still refused
# catchably, so a fold that accepts everything cannot pass, and given `{ a = 1; }` and `{ a = 2; }`
# it is refused where nixpkgs keeps the first file's value without a word (the parity criterion's
# carve-out, owner 2026-09-25).
{ asserts, genMerge }:
let
  read =
    a: b:
    (genMerge.evalModuleTree { } [
      { options.reed = genMerge.mkOption { }; }
      {
        _file = "/demo/warp.nix";
        reed = a;
      }
      {
        _file = "/demo/weft.nix";
        reed = b;
      }
    ]).config.reed;
  attempt = v: builtins.tryEval (builtins.deepSeq v v);
  refused = v: !(attempt v).success;
  doubled = attempt (read "warp" "warp");
  united = attempt (read { warp = 1; } { weft = 2; });
in
{
  construct = [ "untyped-option-merges-by-the-default" ];
  check = asserts (
    doubled.success
    && doubled.value == "warpwarp"
    && united.success
    &&
      united.value == {
        warp = 1;
        weft = 2;
      }
    && refused (read 1 2)
    && refused (read { a = 1; } { a = 2; })
  );
}
