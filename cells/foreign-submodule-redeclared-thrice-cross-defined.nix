# `foreign-submodule-redeclared-thrice-cross-defined` — den-hoag-stage3-rolesmet-nestedtypes-xr243. A
# stock nixpkgs `attrsOf (submodule …)` option is declared three times: one declaration's submodule
# declares `base`, the next only defines it, the third declares a sibling (home-manager's
# `accounts.email.accounts` shape). The declaration fold's intermediate join holds the definer without
# the declarer; nixpkgs never evaluates it, and gen-merge's "one value" read its own evaluation's
# outputs, refusing "option `base' does not exist". gen-merge now compares the module set and leaves
# those outputs unread, and the option resolves to nixpkgs' value. The control: a sub-option no
# declaration declares still refuses, on both engines.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  served =
    eval: mods:
    let
      r = builtins.tryEval (
        let
          v = (eval mods).config.accts.x;
        in
        builtins.deepSeq v v
      );
    in
    if r.success then r.value else null;
  gen = served (modules: genMerge.evalModuleTree { } modules);
  ref = served (modules: lib.evalModules { inherit modules; });
  declares = n: {
    options.${n} = lib.mkOption {
      type = t.int;
      default = 0;
    };
  };
  accts = sub: { options.accts = lib.mkOption { type = t.attrsOf (t.submodule sub); }; };
  thrice = definer: [
    {
      options.accts = lib.mkOption {
        type = t.attrsOf (t.submodule (declares "base"));
        default = { };
      };
    }
    (accts definer)
    (accts (declares "b"))
    { accts.x = { }; }
  ];
  thirds = thrice { config.base = lib.mkDefault 5; };
  undeclared = thrice { config.nope = 5; };
in
{
  construct = [ "redeclared-nixpkgs-submodule-completes-across-three-declarations" ];
  check = asserts (
    gen thirds == ref thirds
    && (gen thirds).base == 5
    && gen undeclared == null
    && ref undeclared == null
  );
}
