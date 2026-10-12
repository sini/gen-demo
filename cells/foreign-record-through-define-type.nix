# `foreign-record-through-define-type` — a-foreign-record-through-define-type-keeps-its-check,
# den-hoag-ukitj (ADR-0025 item 1). A nixpkgs record handed to gen-merge's published
# `types.defineType` keeps its own check: `addCheck` over nixpkgs' `int`, `enum`, `listOf`, `attrsOf` and
# `submodule` refuses what its added check refuses and reads what it admits, declared alone and beside
# its plain base in both orders, and plain nixpkgs `int` still refuses a string. gen-merge used to
# re-complete the record as a gen type with no domain and serve every value. A checked nixpkgs submodule,
# and one copied with a `// { verify }`, keep their checks declared as an option INSIDE a nixpkgs submodule,
# once or twice: the door returns the module set closed under the rebuilds nixpkgs' own evaluation runs.
# Each refusal stands beside its passing twin, so a door refusing everything cannot pass.
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
  # the record declared as an option INSIDE a nixpkgs submodule, whose own evaluation rebuilds it
  host =
    n: x:
    ft.submodule {
      imports = builtins.genList (_: { options.weft = lib.mkOption { type = x; }; }) n;
    };
  nests =
    x: bad: ok:
    builtins.all (n: refused [ (host n x) ] { weft = bad; } && served [ (host n x) ] { weft = ok; }) [
      1
      2
    ];
  verified = sub // {
    verify = v: if (v.warp or 0) == 5 then "warp is 5" else null;
  };
in
{
  construct = [ "a-foreign-record-through-define-type-keeps-its-check" ];
  check = asserts (
    builtins.all holds rows
    && refused [ (genMerge.types.defineType ft.int) ] "sateen"
    && served [ (genMerge.types.defineType ft.int) ] 2
    && nests (genMerge.types.defineType (ft.addCheck sub (v: v.warp != 5))) { warp = 5; } { warp = 2; }
    && nests (genMerge.types.defineType verified) { warp = 5; } { warp = 2; }
  );
}
