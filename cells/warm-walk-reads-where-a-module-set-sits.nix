# `warm-walk-reads-where-a-module-set-sits` — C108, den-hoag-drxbc. `getSubModules` says which module
# set a type is built from, never where its instances sit. The warm identity walk reads the
# placement off the `loc` the declaration a nixpkgs record hands back is stamped with, so a `spool`
# identity under a stock `coercedTo` over `listOf`, or under a `listOf`/`attrsOf` whose `nestedTypes`
# was stripped, is served warm, equal to cold, where it aborted uncatchably. A nixpkgs
# `deferredModuleWith` whose static modules declare `id_hash` holds a MODULE at its position, which
# no declaration field says: the warm read refuses it, catchably, where it aborted. `tryEval` cannot
# read which throw it caught, so T5 row122 reads both refusals by name, this cell's control included.
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
  # a deferred module's value holds `spoolMod`, a function, which has no JSON form
  counted = moved (c: c // { skein = builtins.length c.skein.imports; });
  strip = ty: ty // { nestedTypes = { }; };
  silk.spool = "silk";
  satin.spool = "satin";
in
{
  construct = [ "C108" ];
  check = asserts (
    # a stock coercedTo over a container holds its instances one level below its position
    (plain (t.coercedTo t.str (s: [ { spool = s; } ]) (t.listOf spool)) "silk" "satin").served
    # a container whose nestedTypes was stripped states nothing but its forwarded module set
    && (plain (strip (t.listOf spool)) [ silk ] [ satin ]).served
    && (plain (strip (t.attrsOf spool)) { a = silk; } { a = satin; }).served
    # a module at the position, not an instance: refused, catchably (by name: T5 row122)
    && (counted (t.deferredModuleWith { staticModules = [ spoolMod ]; }) silk satin).refused
    # control: a nixpkgs submodule holds its instance AT its position, and the move is still
    # refused (by gen-memo's name, not the walk's: T5 row122)
    && (plain spool silk satin).refused
  );
}
