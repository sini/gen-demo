# `wrapped-check-recompleted-redeclared` — den-hoag-59gnz. `wrapped-check-redeclared`'s value, nixpkgs
# `addCheck` over gen-merge's `int` admitting `n < 3`, re-completed through gen-merge's two doors that
# take a caller's record, `types.defineType` and `mkOptionType`. Each re-completion keeps the witnesses
# the wrapped value arrived with: declared alone, twice, and beside plain `int` in either order it
# reads `2` and refuses `5`, and `typeEq` refuses it by name beside `int`, as it refuses the raw copy.
# Re-completion used to vouch for the copy with its base's witnesses: `5` was served in seven of the
# eight declaration lists, and the copy compared equal to `int`. The `2`s are the passing twins, so a
# fold refusing every declaration list cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types
      ++ [
        { spool = v; }
      ]
    )).config.spool;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
  int = genMerge.types.int;
  short = lib.types.addCheck int (n: n < 3);
  keepsItsCheck =
    d:
    lib.all (types: read types 2 == 2 && refused (read types 5)) [
      [ d ]
      [
        d
        d
      ]
      [
        int
        d
      ]
      [
        d
        int
      ]
    ]
    && refused (genMerge.types.typeEq int d);
in
{
  construct = [ "a-recompleted-wrapped-value-keeps-its-check" ];
  check = asserts (
    keepsItsCheck (genMerge.types.defineType short) && keepsItsCheck (genMerge.mkOptionType short)
  );
}
