# `list-element-name-is-nixpkgs` — C127, den-hoag-listof-element-name-parity-26thl. A gen `listOf` of a
# gen submodule reading `name` names each element as nixpkgs' `listOf` does, `[definition n-entry m]`:
# `n` the definition's ordinal, `m` the element's index within it, taken before a discharged element
# is dropped. Two definitions, the second holding a discharged `spool` before its survivor, so the
# names are distinct and the survivor's index is 2. It holds on both planes: mounted in nixpkgs'
# own `lib.evalModules`, and in gen-merge's `evalModuleTree`. Each must equal the same construction
# over nixpkgs' types, where gen-merge gave `"0"` to both definitions' elements.
{
  asserts,
  genMerge,
  lib,
}:
let
  spools =
    P: mkOption:
    P.listOf (
      P.submodule (
        { name, ... }:
        {
          options.spool = mkOption {
            type = P.str;
            default = name;
          };
        }
      )
    );
  defs = mkIf: [
    { bobbin = [ { } ]; }
    {
      bobbin = [
        (mkIf false { })
        { }
      ];
    }
  ];
  # `eval` and `mkOption` are the evaluating module system's; `P` and `innerOption` are the type's.
  names =
    eval: mkOption: mkIf: P: innerOption:
    map (s: s.spool)
      (eval {
        modules = [ { options.bobbin = mkOption { type = spools P innerOption; }; } ] ++ defs mkIf;
      }).config.bobbin;
  nixpkgs = names lib.evalModules lib.mkOption lib.mkIf lib.types lib.mkOption;
  foreign = names lib.evalModules lib.mkOption lib.mkIf genMerge.types genMerge.mkOption;
  native = names (
    r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
  ) genMerge.mkOption genMerge.mkIf genMerge.types genMerge.mkOption;
in
{
  construct = [ "list-element-is-named-as-nixpkgs-listof-names-it" ];
  check = asserts (
    nixpkgs == [
      "[definition 1-entry 2]"
      "[definition 2-entry 1]"
    ]
    && foreign == nixpkgs
    && native == nixpkgs
  );
}
