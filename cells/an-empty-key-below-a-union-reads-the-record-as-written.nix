# `an-empty-key-below-a-union-reads-the-record-as-written` — den-hoag-vy14u. nixpkgs' `fixupOptionType`
# rebuilds a declared option's record only where the option's type states a module set, which a union (`either`,
# `oneOf`) or a nulled copy does not, so below one the record written there is the one read: a discharged key of a
# lazy container reads that record's own `emptyValue`, its `//` honoured. Each row is read on gen-merge and on
# nixpkgs' `evalModules`; a refusal reads false. Rows 1-4 diverged before this landing; the last two guard the
# rebuild with no stop above it and a submodule below the union, whose own option is a root.
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
      read =
        type: defs: at:
        let
          r = builtins.tryEval (
            let
              v =
                at
                  (ev [
                    { options.o = L.mkOption { inherit type; }; }
                    { config.o = defs; }
                  ]).config.o;
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
      record = ov: T.listOf sub // ov;
      off = {
        k = L.mkIf false [ ];
      };
    in
    {
      eitherNone = read (T.either (T.lazyAttrsOf (record {
        emptyValue = { };
      })) T.int) off (v: v.k);
      eitherValue = read (T.either (T.lazyAttrsOf (record {
        emptyValue.value = "EV";
      })) T.int) off (v: v.k);
      oneOfSubmoduleNone = read (T.oneOf [
        T.int
        (T.lazyAttrsOf (sub // { emptyValue = { }; }))
      ]) { k = L.mkIf false { }; } (v: v.k);
      nulledNone = read (T.lazyAttrsOf (
        T.lazyAttrsOf (record {
          emptyValue = { };
        })
        // {
          getSubModules = null;
        }
      )) { p = off; } (v: v.p.k);
      bareRebuilt = read (T.lazyAttrsOf (record {
        emptyValue = { };
      })) off (v: v.k);
      submoduleRoot = read (T.either (T.lazyAttrsOf (
        T.submodule {
          options.q = L.mkOption {
            type = T.lazyAttrsOf (record {
              emptyValue = { };
            });
          };
        }
      )) T.int) { k.q = off; } (v: v.k.q.k);
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
  construct = [ "an-empty-key-below-a-union-reads-the-record-as-written" ];
  check = asserts (
    gen == nixpkgs
    &&
      gen == {
        eitherNone = false;
        eitherValue = "EV";
        oneOfSubmoduleNone = false;
        nulledNone = false;
        bareRebuilt = [ ];
        submoduleRoot = [ ];
      }
  );
}
