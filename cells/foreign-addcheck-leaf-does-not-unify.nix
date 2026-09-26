# `foreign-addcheck-leaf-does-not-unify` — C58, den-hoag-0x4hh. nixpkgs' `addCheck` keeps its base's
# `name`, `nestedTypes` and `functor`, so a leaf registry alone minted `addCheck str p` as `str` and
# the hub's `typeEq` answered `true` for two types that accept different values. A foreign record is
# compared, never minted by name (ADR-0034). Live controls: the fixture's two checks disagree on "a",
# and one binding, leaf or `listOf str`, still equals itself, so a `typeEq` answering `false` to
# everything cannot pass.
{ asserts, inputs }:
{
  construct = [ "C58" ];
  check = asserts (
    let
      inherit (inputs.gen.lib.modules.types) typeEq;
      ft = inputs.nixpkgs.lib.types;
      a = ft.addCheck ft.str (s: s != "a");
      b = ft.addCheck ft.str (s: s != "b");
      x = ft.listOf ft.str;
    in
    !(a.check "a") && b.check "a" && !(typeEq a b) && typeEq a a && typeEq x x
  );
}
