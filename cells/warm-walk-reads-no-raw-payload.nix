# `warm-walk-reads-no-raw-payload` — C99, den-hoag-tn3qf (Q1 arm (a), Q2 arm (d)). A functor payload
# is what a type offers to MERGE on, never what it carries. The warm identity walk reads a raw
# nixpkgs record's element from what the record states and finds no position for it there, so it
# stops: a `spool` identity held under nixpkgs' `listOf`, `nullOr` or `functionTo` that an edit
# MOVES is served warm, equal to cold. Before, the first two were walked by rebuilding the payload
# and refused, and `functionTo` aborted uncatchably. And a `nestedTypes` key naming no gen role
# crosses `mkOptionType` verbatim: `coercedTo` keeps `coercedType`/`finalType` and a freeform
# `submodule` keeps `freeformType`, where both used to read `nestedTypes = { }`.
{
  asserts,
  genMerge,
  lib,
}:
let
  inherit (genMerge) evalModuleTree mkOption mkForce;
  gt = genMerge.types;
  t = lib.types;
  spoolMod =
    { config, ... }:
    {
      options.id_hash = mkOption { type = gt.str; };
      options.spool = mkOption {
        type = gt.str;
        default = "";
      };
      config.id_hash = "bobbin:" + builtins.hashString "sha256" config.spool;
    };
  spool = t.submodule spoolMod;
  coldOf = mods: evalModuleTree { } mods;
  warmOf =
    base: edited:
    evalModuleTree {
      warmFrom = coldOf base;
      editedModules = edited;
    } (base ++ edited);
  # a minted instance in the base, so the warm walk is forced
  anchor = [
    { options.reel = mkOption { type = gt.attrsOf (gt.submodule spoolMod); }; }
    {
      _file = "anchor";
      config.reel.a.spool = "anchor";
    }
  ];
  # `read` applies a `functionTo` value, which has no JSON form
  moved =
    read: ty: v: v':
    let
      base = anchor ++ [
        { options.skein = mkOption { type = ty; }; }
        {
          _file = "base";
          config.skein = v;
        }
      ];
      edit = [
        {
          _file = "edit";
          config.skein = mkForce v';
        }
      ];
      w = builtins.tryEval (
        builtins.deepSeq (read (warmOf base edit).config) (read (warmOf base edit).config)
      );
    in
    {
      served =
        w.success && builtins.toJSON w.value == builtins.toJSON (read (coldOf (base ++ edit)).config);
      refused = !w.success;
    };
  plain = moved (c: c);
  applied = moved (c: c // { skein = c.skein null; });
  silk.spool = "silk";
  satin.spool = "satin";
  nested = ty: builtins.attrNames (genMerge.mkOptionType ty).nestedTypes;
in
{
  construct = [ "warm-walk-reads-no-raw-payload" ];
  check = asserts (
    # a moved identity under a raw nixpkgs element carrier is served warm, equal to cold
    (plain (t.listOf spool) [ silk ] [ satin ]).served
    && (plain (t.nullOr spool) silk satin).served
    && (applied (t.functionTo spool) (_: silk) (_: satin)).served
    # control: under gen's own container, which states its position, the move is refused
    && (plain (gt.listOf spool) [ silk ] [ satin ]).refused
    # the unroled keys cross verbatim; the role's spelling is unchanged
    &&
      nested (t.coercedTo t.int toString t.str) == [
        "coercedType"
        "finalType"
      ]
    && nested (t.submodule { freeformType = t.attrsOf t.str; }) == [ "freeformType" ]
    && nested (t.listOf t.str) == [ "elemType" ]
  );
}
