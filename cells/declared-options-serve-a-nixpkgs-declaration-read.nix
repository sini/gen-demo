# `declared-options-serve-a-nixpkgs-declaration-read` — den-hoag-qqywn. gen-merge's `declaredOptions` publishes
# the evaluation's own declarations, so a nixpkgs-grammar declaration that reads `options` (a renamed
# option), a module argument (`with utils;`) or `config` (its presence) reads there as nixpkgs' `.options`
# reads it, where the door used to refuse it, and an untyped declaration (`_module.specialArgs` included)
# reads nixpkgs' `unspecified`, where its record used to have no `type`. The same presence read with a gen
# type keeps ADR-0033's stratum refusal, and a declaration reading nothing is the control, so a door
# serving every read and one refusing every read both fail.
{
  asserts,
  genMerge,
  lib,
}:
let
  door = ms: genMerge.declaredOptions { specialArgs = { inherit lib; }; } ms;
  ref = ms: (lib.evalModules { modules = ms; }).options;
  # one leaf's type name, or a group's key list; `null` where the read refuses catchably
  read =
    at: o:
    let
      r = builtins.tryEval (
        let
          v = lib.attrByPath at null o;
        in
        if (v._type or null) == "option" then v.type.name or "<none>" else builtins.attrNames v
      );
    in
    if r.success then r.value else null;
  int = lib.mkOption {
    type = lib.types.int;
    default = 1;
  };
  untyped = [ { options.weft = lib.mkOption { }; } ];
  sets = {
    rename = {
      at = [ "warp" ];
      ms = [
        (lib.mkRenamedOptionModule [ "warp" ] [ "weft" ])
        { options.weft = int; }
      ];
    };
    argument = {
      at = [ "weft" ];
      ms = [
        { _module.args.loom.mk = int; }
        ({ loom, ... }: { options.weft = loom.mk; })
      ];
    };
    presence = {
      at = [ "weft" ];
      ms = [
        {
          options.shed = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
        }
        ({ config, ... }: { options.weft = if config.shed then { pick = int; } else { }; })
      ];
    };
    untyped = {
      at = [ "weft" ];
      ms = untyped;
    };
    specialArgs = {
      at = [
        "_module"
        "specialArgs"
      ];
      ms = untyped;
    };
    plain = {
      at = [ "weft" ];
      ms = [ { options.weft = int; } ];
    };
  };
  served = builtins.all (
    s:
    let
      d = read s.at (door s.ms);
    in
    d != null && d == read s.at (ref s.ms)
  ) (builtins.attrValues sets);
  genKept =
    read [ "weft" ] (door [
      {
        options.shed = genMerge.mkOption {
          type = genMerge.types.bool;
          default = true;
        };
      }
      (
        { config, ... }:
        {
          options.weft =
            if config.shed then
              {
                pick = genMerge.mkOption {
                  type = genMerge.types.int;
                  default = 1;
                };
              }
            else
              { };
        }
      )
    ]) == null;
in
{
  construct = [ "declared-options-serve-a-nixpkgs-declaration-read" ];
  check = asserts (served && genKept);
}
