# `a-shared-closure-decision-serves-a-staged-keyed-tree` — den-hoag-staged-stratum-inner-eval-nhjxu. The declaration
# guard's walk of a module tree publishes its closure decision where every keyed level dropped nothing but a same-path
# repeat; the value stratum and the staged passes of the same environment re-apply along it, each deciding the dropped
# occurrence against its own holder. The tree here takes that path at the top (keyed modules, a path module twice, a
# declaration that reads `options` so it resolves in a pass) and again in a nested `submodule` child, located: both
# engines read the same value, and it carries both keyed modules' entries once each (the repeat dropped, the import
# kept), at the top and in the child.
{
  asserts,
  genMerge,
  lib,
}:
let
  twill = ../fixtures/shared-closure/twill.nix;
  tree = L: [
    {
      key = "selvage";
      options.weft = L.mkOption {
        type = L.types.listOf L.types.str;
        default = [ ];
      };
      options.shed = L.mkOption {
        type = L.types.int;
        default = 3;
      };
    }
    {
      key = "heddle";
      imports = [
        {
          key = "reed";
          weft = [ "reed" ];
        }
      ];
    }
    (
      { options, ... }:
      {
        options.pick =
          L.mkOption { default = 2; }
          // (if options.shed.type != null then { inherit (options.shed) type; } else { });
      }
    )
    twill
    twill
  ];
  child = L: {
    options.bolt = L.mkOption {
      type = L.types.submodule (tree L);
      default = { };
    };
  };
  read = c: {
    inherit (c) weft pick;
    bolt = { inherit (c.bolt) weft pick; };
  };
  native = mods: read (genMerge.evalModuleTree { } (tree genMerge ++ mods)).config;
  nixpkgs = mods: read (lib.evalModules { modules = tree lib ++ mods; }).config;
  repeat = [ (child genMerge) ];
  repeatNp = [ (child lib) ];
in
{
  construct = [ "a-shared-closure-decision-serves-a-staged-keyed-tree" ];
  check = asserts (
    native repeat == nixpkgs repeatNp
    && builtins.length (native repeat).weft == 2
    && (native repeat).bolt.weft == (native repeat).weft
  );
}
