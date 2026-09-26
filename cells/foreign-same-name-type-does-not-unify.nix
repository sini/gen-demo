# `foreign-same-name-type-does-not-unify` — C80, den-hoag-hc755. A nixpkgs option type's `name` and
# `nestedTypes` do not determine what it accepts: an `addCheck`'d `int` installed at `types.int` by
# `lib.extend`, a gen-merge `mkOptionType` named `int`, and nixpkgs' own `nonEmptyListOf str` (whose
# name is `listOf`) all carry another type's name and structure with a different check. The hub's
# `typeEq` minted each of them as the type whose name it carries and answered `true`. A foreign
# record is now compared, never minted from its name (ADR-0034). `_intern` is the adverse interning
# order. Live controls: each fixture pair really accepts different values, and a type still equals
# itself, a shared binding and its `// { }` copy, so a `typeEq` answering `false` to everything
# cannot pass.
{
  asserts,
  genMerge,
  inputs,
}:
let
  _intern = {
    functor = 0;
  };
in
{
  construct = [ "C80" ];
  check = builtins.seq _intern (
    asserts (
      let
        inherit (inputs.gen.lib.modules.types) typeEq;
        inherit (genMerge) mkOptionType;
        lib = inputs.nixpkgs.lib;
        t = lib.types;
        install =
          f:
          (lib.extend (
            _: p: {
              types = p.types // {
                int = p.types.addCheck p.types.int f;
              };
            }
          )).types;
        pt = install (v: v > 5);
        qt = install (v: v < 3);
        gA = mkOptionType {
          name = "int";
          check = v: builtins.isInt v && v < 10;
        };
        gB = mkOptionType {
          name = "int";
          check = v: builtins.isInt v && v > 100;
        };
        x = t.listOf t.str;
      in
      !(pt.int.check 1)
      && qt.int.check 1
      && gA.check 5
      && !(gB.check 5)
      && !((t.nonEmptyListOf t.str).check [ ])
      && x.check [ ]
      && !(typeEq pt.int t.int)
      && !(typeEq pt.int qt.int)
      && !(typeEq gA gB)
      && !(typeEq gA t.int)
      && !(typeEq (t.nonEmptyListOf t.str) x)
      && typeEq t.int t.int
      && typeEq gA gA
      && typeEq x x
      && typeEq t.port (t.port // { })
    )
  );
}
