# `deep-force-of-a-nesting-type-reads-its-empty-value` — den-hoag-8qenh (ruling 5, the B half). A
# FREE-STANDING `submodule`, one no gen evaluation holds, deep-forces through its empty value, which
# is the bridge's one root evaluation: nixpkgs' `base.config`, the module set over no definitions.
# Each row names its subject and is read on gen-merge and on nixpkgs' `submoduleWith`, so the cell
# compares the two engines rather than a success bit: the throwing twin is false on both sides.
# An evaluation's own type (`(evalModuleTree …).type`) is a held type and is not read here.
{
  asserts,
  genMerge,
  lib,
}:
let
  rows =
    {
      L,
      sub,
      emptyOf,
    }:
    let
      opt = d: L.mkOption { default = d; };
      forces = x: (builtins.tryEval (builtins.deepSeq x true)).success;
      base = {
        options.a = opt 1;
      };
    in
    {
      freeStandingSubmoduleDefaulted = forces (sub [ base ]);
      freeStandingSubmoduleThrowingDefault = forces (sub [ { options.t = opt (throw "T-default"); } ]);
      freeStandingSubmoduleEmptyValueA =
        (builtins.tryEval
          (emptyOf (sub [
            base
            { a = 7; }
          ])).a
        ).value;
    };
  gen = rows {
    L = genMerge;
    sub = genMerge.types.submodule;
    emptyOf = t: t.whenEmpty.value;
  };
  nixpkgs = rows {
    L = lib;
    sub = ms: lib.types.submoduleWith { modules = ms; };
    emptyOf = t: t.emptyValue.value;
  };
in
{
  construct = [ "nesting-type-empty-value-is-its-module-set-over-no-definitions" ];
  check = asserts (
    gen == nixpkgs
    &&
      gen == {
        freeStandingSubmoduleDefaulted = true;
        freeStandingSubmoduleThrowingDefault = false;
        freeStandingSubmoduleEmptyValueA = 7;
      }
  );
}
