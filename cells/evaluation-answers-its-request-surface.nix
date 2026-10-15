# `evaluation-answers-its-request-surface` — den-hoag-l23bt, den-hoag-d2o0g. A loom evaluated with
# `class = "nixos"` and a `shuttle` specialArg reads the `_class` its modules are applied to, and the
# result's `class`, `_type` and `graph`; it is extended once by its own `extendModules` at a stated
# prefix, with the `shuttle` carried rather than restated, and the extension reads its `_class`, its
# `shuttle`, its class and its option's location. Each must equal the same construction over nixpkgs'
# `evalModules`, where gen-merge's door refused `class` by name.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom = L: [
    { options.warp = L.mkOption { default = "w"; }; }
    (
      { _class, shuttle, ... }:
      {
        options.weft = L.mkOption { default = "${_class}-${shuttle}"; };
      }
    )
    {
      _file = "heddle";
      imports = [ { key = "reed"; } ];
    }
  ];
  read =
    ev:
    let
      ext = ev.extendModules {
        prefix = [ "bolt" ];
        modules = [ { warp = "x"; } ];
      };
    in
    {
      inherit (ev) class _type graph;
      inherit (ev.config) weft;
      ext = {
        inherit (ext) class;
        inherit (ext.config) weft warp;
        loc = ext.options.warp.loc;
      };
    };
  request = {
    class = "nixos";
    specialArgs.shuttle = "S";
  };
  gen = read (genMerge.evalModuleTree request (loom genMerge));
  ref = read (lib.evalModules (request // { modules = loom lib; }));
in
{
  construct = [ "an-evaluation-answers-its-request-surface-as-nixpkgs-does" ];
  check = asserts (
    ref.weft == "nixos-S"
    &&
      ref.ext == {
        class = "nixos";
        weft = "nixos-S";
        warp = "x";
        loc = [
          "bolt"
          "warp"
        ];
      }
    && gen == ref
  );
}
