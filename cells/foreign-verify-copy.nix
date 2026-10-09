# `foreign-verify-copy` — a nixpkgs base carrying a `// { verify = …; }` copy keeps the base's own
# `check` over each definition, as nixpkgs' `checkedAndMerged` does: the copy's `verify` judges the
# merged value and cannot stand in for it. `5` given to such a copy of `attrs`, `submodule`, `lines`
# or `attrTag` used to abort uncatchably in the base's raw merge (`{ } // 5`, `concatStringsSep`); it
# is now refused catchably at both doors, beside the same copy serving a value its base admits, so
# a fold refusing everything cannot pass. The message is `refusals` row
# `a-verify-copy-of-a-foreign-base`'s.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "a-verify-copy-of-a-foreign-base-keeps-its-check" ];
  check = asserts (
    let
      np = lib.types;
      read =
        type: v:
        (genMerge.evalModuleTree { } [
          { options.spool = genMerge.mkOption { inherit type; }; }
          { spool = v; }
        ]).config.spool;
      copy = T: T // { verify = _: null; };
      bases = [
        np.attrs
        (np.submodule { options.warp = lib.mkOption { type = np.str; }; })
        np.lines
        (np.attrTag { warp = lib.mkOption { type = np.str; }; })
      ];
      refused = type: !(builtins.tryEval (builtins.deepSeq (read type 5) null)).success;
    in
    builtins.all (T: refused (copy T) && refused (genMerge.mkOptionType (copy T))) bases
    && read (copy np.attrs) { warp = "sateen"; } == { warp = "sateen"; }
    && read (genMerge.mkOptionType (copy np.lines)) "sateen" == "sateen"
  );
}
