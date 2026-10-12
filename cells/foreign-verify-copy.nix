# `foreign-verify-copy` — den-hoag-bm1s5. A nixpkgs base carrying a `// { verify = …; }` copy keeps
# the base's own `check` over each definition, as nixpkgs' `checkedAndMerged` does: the copy's
# `verify` judges the merged value and cannot stand in for it. `5` given to such a copy of `attrs`,
# `submodule`, `lines` or `attrTag` used to abort uncatchably in the base's raw merge (`{ } // 5`,
# `concatStringsSep`); it is now refused catchably at both doors, beside the same copy serving a
# value its base admits, so a fold refusing everything cannot pass. The message is `refusals` row
# `a-verify-copy-of-a-foreign-base`'s. The copy's `verify` reads the MERGED value of a redeclared option
# too: a submodule copy whose `verify` needs a field another declaration's submodule states, defined
# across two definitions, is served raw, through `types.defineType` and through `mkOptionType`, beside
# that submodule in either order, and the one definition it rejects alone is refused.
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
      # a definition list over a declaration list, tried
      readAll =
        types: defs:
        builtins.tryEval (
          let
            x =
              (genMerge.evalModuleTree { } (
                map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types
                ++ map (d: { spool = d; }) defs
              )).config.spool;
          in
          builtins.deepSeq x x
        );
      int0 = lib.mkOption {
        type = np.int;
        default = 0;
      };
      warpOnly = np.submodule { options.warp = int0; };
      weftOnly = np.submodule { options.weft = int0; };
      needsWeft = warpOnly // {
        verify = v: if (v.warp or 0) == 5 && (v.weft or 0) == 0 then "a warp of 5 needs a weft" else null;
      };
      split =
        types:
        (readAll types [
          { warp = 5; }
          { weft = 1; }
        ]).value == {
          warp = 5;
          weft = 1;
        }
        && !(readAll types [ { warp = 5; } ]).success;
      merged =
        lib.all
          (
            door:
            split [
              weftOnly
              (door needsWeft)
            ]
            && split [
              (door needsWeft)
              weftOnly
            ]
          )
          [
            (d: d)
            genMerge.types.defineType
            genMerge.mkOptionType
          ];
    in
    builtins.all (T: refused (copy T) && refused (genMerge.mkOptionType (copy T))) bases
    && read (copy np.attrs) { warp = "sateen"; } == { warp = "sateen"; }
    && read (genMerge.mkOptionType (copy np.lines)) "sateen" == "sateen"
    && merged
  );
}
