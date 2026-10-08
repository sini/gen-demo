# `wrapped-check-recompleted-redeclared` — den-hoag-59gnz. `wrapped-check-redeclared`'s value, nixpkgs
# `addCheck` over gen-merge's `int` admitting `n < 3`, re-completed through gen-merge's two doors that
# take a caller's record, `types.defineType` and `mkOptionType`. Each re-completion keeps the witnesses
# the wrapped value arrived with: declared alone, twice, and beside plain `int` in either order it
# reads `2` and refuses `5`; demanding its identity (gen-types' `idOf`) is refused, catchably, because
# its mark names its base; and `typeEq` never takes it for `int`. Re-completion used to vouch for the
# copy with its base's witnesses: `5` was served in seven of the eight declaration lists, and the
# `defineType` copy had `int`'s identity and `typeEq` took it for `int`. The `2`s are the passing
# twins, so a fold refusing every declaration list cannot pass, and `int`'s own identity is demanded
# beside the copies, so an `idOf` refusing everything cannot pass either.
{
  asserts,
  genMerge,
  inputs,
  lib,
}:
let
  inherit (inputs.gen.lib.modules.types) idOf;
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types
      ++ [
        { spool = v; }
      ]
    )).config.spool;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
  # `typeEq` answers `true` for the copy only if re-completion vouched for it with `int`'s witnesses;
  # it refuses it by name or answers `false`
  sameAsInt =
    d:
    builtins.tryEval (genMerge.types.typeEq int d) == {
      success = true;
      value = true;
    };
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
    && refused (idOf d)
    && !(sameAsInt d);
in
{
  construct = [ "a-recompleted-wrapped-value-keeps-its-check" ];
  check = asserts (
    !(refused (idOf int))
    && keepsItsCheck (genMerge.types.defineType short)
    && keepsItsCheck (genMerge.mkOptionType short)
  );
}
