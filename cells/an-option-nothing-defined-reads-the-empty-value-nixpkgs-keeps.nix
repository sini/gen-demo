# `an-option-nothing-defined-reads-the-empty-value-nixpkgs-keeps` — den-hoag-omf1j. With no surviving
# definition an option reads its type's empty value, and the record read is the one nixpkgs keeps: a `//` over
# `emptyValue` is honoured on a record nixpkgs keeps and dropped where `fixupOptionType` rebuilds it (a record
# stating a module set) or a second declaration joins it; a `//` over gen's own `whenEmpty` is no nixpkgs field.
# Each row is read on gen-merge and on nixpkgs' `evalModules`, so the cell compares the two engines; a refusal reads
# false. Rows 1-3 and the last diverged before this landing; rows 4-5 guard the rebuild and the join, and the
# undefined foreign row guards the rebuild's own empty value (services.mtr-exporter.jobs).
{
  asserts,
  genMerge,
  lib,
}:
let
  rows =
    { L, ev }:
    let
      T = L.types;
      at = atWith [ { config.o = L.mkIf false [ ]; } ];
      atWith =
        defs: n: type:
        let
          r = builtins.tryEval (
            let
              v = (ev (builtins.genList (_: { options.o = L.mkOption { inherit type; }; }) n ++ defs)).config.o;
            in
            builtins.deepSeq v v
          );
        in
        if r.success then r.value else false;
      sub = T.submodule {
        options.a = L.mkOption {
          type = T.str;
          default = "x";
        };
      };
      twice = T.listOf T.str // {
        check = _: false;
        emptyValue = { };
      };
      # nixpkgs' own `nonEmptyListOf (submodule …)`, services.mtr-exporter.jobs' type, read on both engines
      nel = lib.types.nonEmptyListOf (
        lib.types.submodule { options.a = lib.mkOption { type = lib.types.str; }; }
      );
    in
    {
      keptNone = at 1 (T.listOf T.str // { emptyValue = { }; });
      keptValue = at 1 (T.str // { emptyValue.value = "EV"; });
      genWordOnly = at 1 (T.listOf T.str // { whenEmpty = { }; });
      rebuiltNone = at 1 (T.listOf sub // { emptyValue = { }; });
      joinedNone = at 2 twice;
      control = at 1 (T.listOf T.str);
      foreignNonEmptyUndefined = atWith [ ] 1 nel;
      foreignNonEmptyDischarged = at 1 nel;
    };
  gen = rows {
    L = genMerge;
    ev = genMerge.evalModuleTree { };
  };
  nixpkgs = rows {
    L = lib;
    ev = modules: lib.evalModules { inherit modules; };
  };
in
{
  construct = [ "an-option-nothing-defined-reads-the-empty-value-nixpkgs-keeps" ];
  check = asserts (
    gen == nixpkgs
    &&
      gen == {
        keptNone = false;
        keptValue = "EV";
        genWordOnly = [ ];
        rebuiltNone = [ ];
        joinedNone = [ ];
        control = [ ];
        foreignNonEmptyUndefined = false;
        foreignNonEmptyDischarged = false;
      }
  );
}
