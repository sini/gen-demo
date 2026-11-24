# ── an instance's evaluation retained by its caller (den-hoag-t5ndo 1b) ──
# den composes a user across layers, and reads each layer's `config` and `provenance`. gen-schema's
# `evalInstance { } type loc defs` returns `{ config; provenance; }` of the one evaluation the instance type's
# exported `merge` makes over `defs`, so `config` is the typed value and `provenance` is that same evaluation's.
# A den-shaped instance type (non-strict, a freeform `attrsOf anything`, a type-own module contributing `groups`
# at the band of an entry) is mounted under nixpkgs' `attrsOf`, as den's host relation mounts it, and each
# element is evaluated through the door. A copy of the type carrying a sibling's fold and tree by `//` is
# refused, where its exported `merge` serves the record's own child.
{
  genMerge,
  inputs,
  lib,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  kind =
    (schema.evalSchema { } [
      {
        config.schema.user = {
          options.shell = genMerge.mkOption {
            type = T.str;
            default = "bash";
          };
          options.groups = genMerge.mkOption {
            type = T.listOf T.str;
            default = [ ];
          };
        };
      }
    ]).user;
  typeWith =
    mods:
    schema.mkInstanceType {
      extraModules = mods;
      strict = false;
    } kind;
  schemaMod = {
    _file = "schema.nix";
    groups = [ "base" ];
  };
  userType = typeWith [ schemaMod ];
  siblingType = typeWith [
    schemaMod
    {
      options.o9 = genMerge.mkOption {
        type = T.int;
        default = 9;
      };
    }
  ];
  loc = [
    "users"
    "tux"
  ];
  defs = [
    {
      file = "host.nix";
      value = {
        shell = "fish";
        groups = [ "video" ];
        ff = 7;
      };
    }
  ];
  host = lib.evalModules {
    modules = [
      { options.users = lib.mkOption { type = lib.types.attrsOf userType; }; }
      {
        _file = "host.nix";
        users.tux = {
          shell = "fish";
          groups = [ "video" ];
          ff = 7;
        };
      }
    ];
  };
  kept = host.options.users.type.nestedTypes.elemType;
  r = schema.evalInstance { } kept loc defs;
  served =
    e:
    let
      v = builtins.tryEval (builtins.deepSeq e e);
    in
    v.success;
  forged = userType // {
    inherit (siblingType) mergeDefs nests;
  };
in
{
  retainedInstanceArms = {
    configIsTheTypedValue = r.config == host.config.users.tux;
    configIsTheExportedMerge =
      (schema.evalInstance { } userType loc defs).config == userType.merge loc defs;
    keys = builtins.attrNames r;
    groupsWinners = map (w: w.file) r.provenance.groups.winners;
    inherit (r.config) groups;
    forgedRefused = !served (schema.evalInstance { } forged loc defs).config;
    forgedMergeServes = served (forged.merge loc defs);
    unknownOptionRefused = !served (schema.evalInstance { bogus = 1; } userType loc defs).config;
  };
}
