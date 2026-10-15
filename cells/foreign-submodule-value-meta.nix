# `foreign-submodule-value-meta` — den-hoag-xroc7. An option declared with nixpkgs' `attrsOf (submodule …)`
# answers nixpkgs' v2-merge metadata on gen-merge's evaluated record, each element's `configuration` the
# value gen-merge's own fold returned: `lib.modules.mapAttrsOfSubmodule` over it reads each element's config
# and option priority as it does over nixpkgs' own `lib.evalModules`, where gen-merge refused the read by
# name. A gen-merge `verify` copy inside the submodule rejects a definition: the value refuses, and so does
# the configuration carrying it, so a record serving every read cannot pass.

{
  asserts,
  genMerge,
  lib,
}:

let
  heddle = lib.types.submodule {
    options.shed = lib.mkOption {
      type = lib.types.int;
      default = 2;
    };
  };
  modules = [
    { options.looms = lib.mkOption { type = lib.types.attrsOf heddle; }; }
    {
      config.looms.dobby.shed = lib.mkDefault 4;
      config.looms.jacquard = { };
    }
  ];
  read =
    ev:
    lib.modules.mapAttrsOfSubmodule (_: { cfg, opt }: {
      inherit cfg;
      prio = opt.shed.highestPrio;
    }) ev.options.looms;
  native = read (genMerge.evalModuleTree { } modules);
  nixpkgs = read (lib.evalModules { inherit modules; });
  expected = {
    dobby = {
      cfg.shed = 4;
      prio = 1000;
    };
    jacquard = {
      cfg.shed = 2;
      prio = 1500;
    };
  };
  copy = genMerge.types.int // {
    verify = v: if v == 7 then "a shed of 7 is refused" else genMerge.types.int.verify v;
  };
  guarded = genMerge.evalModuleTree { } [
    {
      options.looms = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule { options.shed = lib.mkOption { type = copy; }; });
      };
      config.looms.dobby.shed = 7;
    }
  ];
  refuses = x: !(builtins.tryEval (builtins.deepSeq x null)).success;
in

{
  construct = [ "a-foreign-submodule-option-answers-its-configurations" ];
  check = asserts (
    native == expected
    && nixpkgs == expected
    && refuses guarded.config.looms
    && refuses guarded.options.looms.valueMeta.attrs.dobby.configuration.config
    && refuses guarded.options.looms.valueMeta.attrs.dobby.configuration.options.shed.value
  );
}
