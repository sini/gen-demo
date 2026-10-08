# `foreign-record-through-define-type` — a-foreign-record-through-define-type-keeps-its-check,
# den-hoag-ukitj (ADR-0025 item 1). A nixpkgs record handed to gen-merge's published
# `types.defineType` keeps its own check: `addCheck` over nixpkgs' `int`, `enum`, `listOf`, `attrsOf` and
# `submodule` refuses what its added check refuses and reads what it admits, declared alone and beside
# its plain base in both orders, and plain nixpkgs `int` still refuses a string. gen-merge used to
# re-complete the record as a gen type with no domain and serve every value. Each refusal stands beside
# its passing twin, so a door refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types ++ [ { spool = v; } ]
    )).config.spool;
  refused = types: v: !(builtins.tryEval (builtins.deepSeq (read types v) null)).success;
  served = types: v: read types v == v;
  sub = ft.submodule { options.warp = lib.mkOption { type = ft.int; }; };
  # base, the value the added check rejects, a value it admits
  rows = [
    {
      t = ft.int;
      bad = 5;
      ok = 2;
    }
    {
      t = ft.enum [
        "plain"
        "twill"
      ];
      bad = "plain";
      ok = "twill";
    }
    {
      t = ft.listOf ft.int;
      bad = [ 5 ];
      ok = [ 2 ];
    }
    {
      t = ft.attrsOf ft.int;
      bad = {
        a = 5;
      };
      ok = {
        b = 2;
      };
    }
    {
      t = sub;
      bad = {
        warp = 5;
      };
      ok = {
        warp = 2;
      };
    }
  ];
  holds =
    r:
    let
      x = genMerge.types.defineType (ft.addCheck r.t (v: v != r.bad));
    in
    refused [ x ] r.bad
    && served [ x ] r.ok
    && refused [ r.t x ] r.bad
    && refused [ x r.t ] r.bad
    && served [ r.t x ] r.ok
    && served [ x r.t ] r.ok;
in
{
  construct = [ "a-foreign-record-through-define-type-keeps-its-check" ];
  check = asserts (
    builtins.all holds rows
    && refused [ (genMerge.types.defineType ft.int) ] "sateen"
    && served [ (genMerge.types.defineType ft.int) ] 2
  );
}
