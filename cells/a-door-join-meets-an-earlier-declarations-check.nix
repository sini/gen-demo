# `a-door-join-meets-an-earlier-declarations-check` — den-hoag-pfbow. nixpkgs' `evalModules` merges a redeclared
# option's types last declaration first, handing the receiver only each earlier declaration's functor. A type crossing
# gen-merge's `defineType` names itself as the declaration there, so its join meets an earlier declaration's check:
# a value it rejects is refused where nixpkgs' all-nixpkgs twin serves it (nixpkgs drops `addCheck` at every
# redeclaration, ADR-0039 THE MEET), a value it admits is served as the twin serves it, and two enums still join as a
# union with a check owed inside its own enum only. Every row is read in nixpkgs' `evalModules`; a refusal reads false.
# Rows `tagRejected`, `selfRejected` and `unionA` diverged before this landing (served 1 / 1 and refused).
{
  asserts,
  genMerge,
  lib,
}:
let
  T = lib.types;
  read =
    types: def:
    let
      r = builtins.tryEval (
        let
          v =
            (lib.evalModules {
              modules = map (t: { options.o = lib.mkOption { type = genMerge.types.defineType t; }; }) types ++ [
                { config.o = def; }
              ];
            }).config.o;
        in
        builtins.deepSeq v v
      );
    in
    if r.success then r.value else false;
  notOne = v: v != 1;
  sub = T.submodule {
    options.a = lib.mkOption {
      type = T.str;
      default = "x";
    };
  };
  tag =
    b:
    T.attrTag {
      a = lib.mkOption { type = sub; };
      b = lib.mkOption { type = b; };
    };
  # a type whose own `typeMerge` hands itself back as written
  self =
    let
      k =
        lib.mkOptionType {
          name = "kint";
          check = builtins.isInt;
          merge = lib.mergeEqualOption;
          functor = {
            name = "kint";
            type = null;
            wrapped = null;
            payload = { };
            binOp = _: _: null;
          };
        }
        // {
          typeMerge = _: k;
        };
    in
    k;
  selfChecked = self // {
    check = v: self.check v && notOne v;
    functor = self.functor // {
      payload.keep = true;
    };
  };
  rows = {
    tagRejected = read [ (tag (T.addCheck T.int notOne)) (tag T.int) ] { b = 1; };
    tagAdmitted = read [ (tag (T.addCheck T.int notOne)) (tag T.int) ] { b = 2; };
    selfRejected = read [ selfChecked self ] 1;
    selfAdmitted = read [ selfChecked self ] 2;
    unionA = read [
      (T.enum [ "a" ])
      (T.enum [ "b" ])
    ] "a";
    unionB = read [
      (T.enum [ "a" ])
      (T.enum [ "b" ])
    ] "b";
    ownEnumRejected = read [
      (T.addCheck (T.enum [
        "a"
        "c"
      ]) (v: v != "a"))
      (T.enum [ "b" ])
    ] "a";
  };
in
{
  construct = [ "a-door-join-meets-an-earlier-declarations-check" ];
  check = asserts (
    rows == {
      tagRejected = false;
      tagAdmitted = {
        b = 2;
      };
      selfRejected = false;
      selfAdmitted = 2;
      unionA = "a";
      unionB = "b";
      ownEnumRejected = false;
    }
  );
}
