# `mkoptiontype-shared-key-identity` — C69, den-hoag-jzatq. A check-only `mkOptionType` decides a
# shared attrset key with `==` on each definer's own value, so one function bound once and written
# in two files, `heddle = { a = spin; }` twice, reads `[ "a" ]` on Nix, Determinate and Lix alike,
# where Nix and Determinate used to refuse the pair and Lix kept it. The same holds for one function
# passed to both modules through `specialArgs`: a `specialArgs` formal is that attribute itself, not
# a copy. Beside them, two DIFFERENT closures of one lambda are still refused catchably on all three,
# so a fold that calls every shared function equal cannot pass.
{ asserts, genMerge }:
let
  thread = genMerge.mkOptionType {
    name = "thread";
    check = builtins.isAttrs;
  };
  decl = {
    options.heddle = genMerge.mkOption { type = thread; };
  };
  spin = x: x + 1;
  twist = _: x: x;
  read =
    args: modules: (genMerge.evalModuleTree (args // { modules = [ decl ] ++ modules; })).config.heddle;
  pair =
    a: b:
    read { } [
      {
        _file = "/demo/warp.nix";
        heddle = a;
      }
      {
        _file = "/demo/weft.nix";
        heddle = b;
      }
    ];
  viaArg = file: { spin, ... }: {
    _file = file;
    heddle = {
      a = spin;
    };
  };
  keys = v: builtins.tryEval (builtins.attrNames v);
  kept =
    v:
    keys v == {
      success = true;
      value = [ "a" ];
    };
in
{
  construct = [ "C69" ];
  check = asserts (
    kept (pair { a = spin; } { a = spin; })
    && kept (
      read { specialArgs = { inherit spin; }; } [
        (viaArg "/demo/warp.nix")
        (viaArg "/demo/weft.nix")
      ]
    )
    && !(keys (pair { a = twist 1; } { a = twist 2; })).success
  );
}
