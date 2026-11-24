# `a-function-body-nothing-defined-reads-the-record-as-written` — den-hoag-kc84t. Below a root whose fix-up
# rebuilds nothing (`either`, `oneOf`), nixpkgs' `functionTo` merges a function body nothing defined against the
# element record written there, so the body reads that record's own `emptyValue`, its `//` honoured, also through a
# foreign wrapper between `functionTo` and the record. Each row is read on gen-merge and on nixpkgs' `evalModules`;
# genMerge publishes no `functionTo`, so nixpkgs' is the container on both sides, and a refusal reads false. Rows 1-3
# diverged before this landing; the check rows refuse a body the record's own check rejects, and the last two guard
# the rebuild where nothing above stops it.
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
      F = lib.types.functionTo;
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
      record = T.listOf sub // {
        emptyValue.value = "EV";
      };
      body = _: L.mkIf false [ ];
    in
    {
      keyed = read (T.either (T.attrsOf (F record)) T.int) { k = body; } (v: v.k null);
      lazyKeyed = read (T.oneOf [
        T.int
        (T.lazyAttrsOf (F record))
      ]) { k = body; } (v: v.k null);
      keyedThroughUniq = read (T.either (T.attrsOf (F (lib.types.uniq record))) T.int) { k = body; } (
        v: v.k null
      );
      keyedRejects = read (T.either (T.attrsOf (F record)) T.int) { k = _: "x"; } (v: v.k null);
      bareRebuilt = read (T.attrsOf (F record)) { k = body; } (v: v.k null);
      nullRebuilt = read (T.nullOr (T.attrsOf (F record))) { k = body; } (v: v.k null);
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
  construct = [ "a-function-body-nothing-defined-reads-the-record-as-written" ];
  check = asserts (
    gen == nixpkgs
    &&
      gen == {
        keyed = "EV";
        lazyKeyed = "EV";
        keyedThroughUniq = "EV";
        keyedRejects = false;
        bareRebuilt = [ ];
        nullRebuilt = [ ];
      }
  );
}
