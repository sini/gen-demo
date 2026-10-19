# `gen-nesting-types-read-their-own-modules-first` — den-hoag-yjmwc. A loom declared in `heddle.nix` states a `frame`
# option of a gen-merge `submodule` and a `bolts` option of a gen-merge `attrsOf` of it, whose own module states
# `threads = [ "warp" ]` and imports a module stating `threads = [ "selvage" ]`; `loom.nix` and `shed.nix` each define
# `threads` too. nixpkgs locates the type's own module one level below the definitions and reads it first:
# `[ "selvage" "warp" "loom" "shed" ]`. gen-merge read it after the definitions, `[ "selvage" "loom" "shed" "warp" ]`,
# the own module beside them. Each must equal the same loom over nixpkgs' `evalModules`.

{
  asserts,
  genMerge,
  lib,
}:

let
  # the nesting family is the engine's own: gen-merge's on gen's engine, nixpkgs' on nixpkgs'
  loom = T: M: [
    {
      _file = "heddle.nix";
      options.frame = M.mkOption { type = T.submodule warp; };
      options.bolts = M.mkOption {
        type = T.attrsOf (T.submodule warp);
        default = { };
      };
    }
    {
      _file = "loom.nix";
      frame.threads = [ "loom" ];
      bolts.b.threads = [ "loom" ];
    }
    {
      _file = "shed.nix";
      frame.threads = [ "shed" ];
      bolts.b.threads = [ "shed" ];
    }
  ];
  warp = {
    imports = [
      {
        options.threads = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      }
      { threads = [ "selvage" ]; }
    ];
    threads = [ "warp" ];
  };
  read = ev: {
    frame = ev.config.frame.threads;
    bolt = ev.config.bolts.b.threads;
  };
  gen = read (genMerge.evalModuleTree { } (loom genMerge.types genMerge));
  ref = read (lib.evalModules { modules = loom lib.types lib; });
in

{
  construct = [ "a-nested-evaluation-orders-its-definitions-as-nixpkgs-does" ];
  check = asserts (
    ref == {
      frame = [
        "selvage"
        "warp"
        "loom"
        "shed"
      ];
      bolt = [
        "selvage"
        "warp"
        "loom"
        "shed"
      ];
    }
    && gen == ref
  );
}
