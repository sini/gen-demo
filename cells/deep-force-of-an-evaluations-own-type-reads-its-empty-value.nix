# `deep-force-of-an-evaluations-own-type-reads-its-empty-value` — den-hoag-8qenh (OQ6 (c′), the C
# half). An evaluation's OWN type (`(evalModuleTree …).type`), a held type, deep-forces through its
# empty value, which is that evaluation's on-demand `type` child: nixpkgs' `base.config`, the module
# set over no definitions. Each row is read on gen-merge and on nixpkgs' `evalModules`, so the cell
# compares the two engines rather than a success bit: the throwing twin is false on both sides. It
# refused by name before the C landing.
{
  asserts,
  genMerge,
  lib,
}:
let
  rows =
    {
      L,
      ev,
      emptyOf,
    }:
    let
      opt = d: L.mkOption { default = d; };
      forces = x: (builtins.tryEval (builtins.deepSeq x true)).success;
      base.options.a = opt 1;
    in
    {
      ownTypeDefaulted = forces (ev [ base ]).type;
      ownTypeThrowingDefault = forces (ev [ { options.t = opt (throw "T-default"); } ]).type;
      ownTypeInAttrsOf = forces (L.types.attrsOf (ev [ base ]).type);
      ownTypeEmptyValueA =
        (builtins.tryEval
          (emptyOf
            (ev [
              base
              { a = 7; }
            ]).type
          ).a
        ).value;
    };
  gen = rows {
    L = genMerge;
    ev = genMerge.evalModuleTree { };
    emptyOf = t: t.whenEmpty.value;
  };
  nixpkgs = rows {
    L = lib;
    ev = modules: lib.evalModules { inherit modules; };
    emptyOf = t: t.emptyValue.value;
  };
in
{
  construct = [ "nesting-type-empty-value-is-its-module-set-over-no-definitions" ];
  check = asserts (
    gen == nixpkgs
    &&
      gen == {
        ownTypeDefaulted = true;
        ownTypeThrowingDefault = false;
        ownTypeInAttrsOf = true;
        ownTypeEmptyValueA = 7;
      }
  );
}
