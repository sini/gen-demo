# `an-extension-naming-its-module-argument-is-published-unread` — den-hoag-stage3-own-holds-deep-eq-p16jh.
# home-manager's misc/specialisation.nix types an option by
# `(extendModules { modules = [ { _module.args.name = mkForce name; … } ]; }).type` where the top level defines no `name`.
# Publishing that type's module set reads nothing of the extension's values in nixpkgs. gen-merge decided whether the
# set's last module was its own name placeholder by a deep `==`, which forced the extension's `name` and refused
# (`module argument `name' is not defined`). `deep` is equal to the placeholder in every compared pair but `content`,
# so the old comparison reaches `name` under every symbol order; `hm` is home-manager's own shape, which it reached
# only under some orders. `lookAlike` is a user module equal to the placeholder: nixpkgs publishes it as the user's
# module, last; gen took it for its placeholder and published `P` first instead (read as a class string: `P` a module
# whose `name` is an override record, `F` a function module, `M` any other).
{
  asserts,
  genMerge,
  lib,
}:
let
  rows =
    { L, ev }:
    let
      tries =
        x:
        let
          r = builtins.tryEval (builtins.deepSeq x x);
        in
        if r.success then r.value else "refused";
      publish =
        ext:
        (ev [
          (
            { name, extendModules, ... }:
            {
              options.specialisation = L.mkOption {
                type = (extendModules { modules = [ (ext name) ]; }).type;
                default = { };
              };
            }
          )
        ]).options.specialisation.type.getSubModules;
      cls =
        m0:
        let
          m = if builtins.isAttrs m0 && m0 ? imports then builtins.head m0.imports else m0;
        in
        if builtins.isFunction m then
          "F"
        else if builtins.isAttrs m && (m._module.args.name._type or null) == "override" then
          "P"
        else
          "M";
    in
    {
      deep = tries (
        builtins.length (
          publish (name: {
            _file = "<unknown-file>";
            _module.args.name = L.mkOptionDefault name;
          })
        )
      );
      hm = tries (
        builtins.length (
          publish (name: {
            specialisation = L.mkOverride 0 { };
            _module.args.name = L.mkForce name;
          })
        )
      );
      lookAlike = tries (
        builtins.concatStringsSep "" (
          map cls (
            publish (_: {
              _file = "<unknown-file>";
              _module.args.name = L.mkOptionDefault "‹name›";
            })
          )
        )
      );
    };
  gen = rows {
    L = genMerge;
    ev = genMerge.evalModuleTree { };
  };
  ref = rows {
    L = lib;
    ev = modules: lib.evalModules { inherit modules; };
  };
in
{
  construct = [ "an-evaluation-publishes-its-extension-unread-as-nixpkgs-does" ];
  check = asserts (
    ref == {
      deep = 2;
      hm = 2;
      lookAlike = "FP";
    }
    && gen == ref
  );
}
