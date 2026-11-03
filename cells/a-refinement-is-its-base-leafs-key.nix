# `a-refinement-is-its-base-leafs-key` — den-hoag-mq05m. A nixpkgs refinement keeps its base's functor under a name of its
# own (`ints.positive` is `positiveInt` over functor `int`, `port` is `u16` over `int`), and nixpkgs keys a redeclared
# option on the FUNCTOR name. So gen's `int` declared beside a refinement is one key, in either order, raw and through
# each door (`genMerge.mkOptionType`, `genMerge.types.mkOptionType`): a value both checks admit is served, and one the
# refinement rejects is refused, since gen's meet owes both declared checks. gen-merge keyed the foreign partner by its
# type NAME, so it refused the passing value where gen's `int` came later. Each refusal stands beside its passing twin,
# so a fold refusing everything cannot pass, and neither can one serving everything.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  inherit (genMerge.types) int;
  doors = {
    raw = x: x;
    d1 = genMerge.mkOptionType;
    d2 = genMerge.types.mkOptionType;
  };
  attempt =
    types: v:
    builtins.tryEval (
      let
        o = genMerge.evalModuleTree { } (
          map (type: { options.pins = genMerge.mkOption { inherit type; }; }) types ++ [ { pins = v; } ]
        );
      in
      builtins.deepSeq o.config.pins o.config.pins
    );
  served =
    types: v:
    attempt types v == {
      success = true;
      value = v;
    };
  refused = types: v: !(attempt types v).success;
  # a refinement over `int`, a value it admits and one gen's `int` admits that it rejects
  refinements = [
    {
      r = t.ints.positive;
      ok = 2;
      bad = -1;
    }
    {
      r = t.ints.between 0 9;
      ok = 2;
      bad = 10;
    }
    {
      r = t.port;
      ok = 2;
      bad = 70000;
    }
  ];
  orders = r: [
    [
      int
      r
    ]
    [
      r
      int
    ]
  ];
in
{
  construct = [ "a-refinement-is-its-base-leafs-key" ];
  check = asserts (
    lib.all (
      c:
      lib.all (d: lib.all (ts: served ts c.ok && refused ts c.bad) (orders (doors.${d} c.r))) (
        builtins.attrNames doors
      )
    ) refinements
  );
}
