# `option-default-seeds-the-fold` — den-hoag-12e7r. An option's declared `default` that survives the
# priority filter beside a priority-1500 definition (`mkOptionDefault`, `mkOverride 1500`) is the FIRST
# definition the fold sees, as in nixpkgs' `evalOptionValue`, so an order-sensitive merge serves the
# default first: `listOf` gives `[ "base" "late" "early" ]` on both engines where gen-merge served the
# default last. The same seed reaches a nested tree (`submodule`), where nixpkgs' module reversal puts it
# last. The control is a plain definition beside the default: the filter drops the default, and both
# engines read the definition alone.

{
  asserts,
  genMerge,
  lib,
}:

let
  modules = M: [
    {
      _file = "/kiln/decl.nix";
      options.shelf = M.mkOption {
        type = M.types.listOf M.types.str;
        default = [ "base" ];
      };
      options.rack = M.mkOption {
        type = M.types.submodule {
          options.slots = M.mkOption { type = M.types.listOf M.types.str; };
        };
        default.slots = [ "base" ];
      };
      options.plain = M.mkOption {
        type = M.types.listOf M.types.str;
        default = [ "base" ];
      };
      config.shelf = M.mkOptionDefault [ "early" ];
    }
    {
      _file = "/kiln/late.nix";
      config.shelf = M.mkOverride 1500 [ "late" ];
      config.rack = M.mkOptionDefault { slots = [ "late" ]; };
      config.plain = [ "set" ];
    }
  ];
  read = ev: {
    inherit (ev.config) shelf plain;
    inherit (ev.config.rack) slots;
  };
  native = read (genMerge.evalModuleTree { } (modules genMerge));
  nixpkgs = read (lib.evalModules { modules = modules lib; });
  expected = {
    shelf = [
      "base"
      "late"
      "early"
    ];
    slots = [
      "late"
      "base"
    ];
    plain = [ "set" ];
  };
in

{
  construct = [ "an-option-default-seeds-the-definition-fold" ];
  check = asserts (native == expected && nixpkgs == expected);
}
