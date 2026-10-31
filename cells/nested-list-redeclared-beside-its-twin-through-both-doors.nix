# `nested-list-redeclared-beside-its-twin-through-both-doors` — den-hoag-redeclaration-beside-foreign-slope-vhcac. One
# option is declared N = 2..4 times: gen's `attrsOf` over nixpkgs' `listOf (listOf int)`, beside that type's nixpkgs twin
# placed through each door (`genMerge.mkOptionType`, `genMerge.types.mkOptionType`) and raw, every declaration
# (N − 1 gen, one partner) in both orders. gen-merge's meet compares the operands' parameter trees once per step and reads
# them role by role, and a gen container relation whose element is the pair's own met descends once. The served value
# is nixpkgs' own `evalModules` answer over the same declarations without the doors, in every order and door.
# The closing case: a partner whose inner list is nixpkgs' `addCheck` rejecting `[ 7 ]` keeps its check at depth, so
# `{ k = [ [ 7 ] ]; }` is refused in every order and door while `{ k = [ [ 8 ] ]; }` is served.
# This cell is EXERCISE for the cost, not its oracle: the per-option slope in N and in depth is read by thunk counts in the
# den-hoag-vhcac-c1 build report, which a pure evaluation cannot take.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  inner = t.listOf (t.listOf t.int);
  checked = t.listOf (t.addCheck (t.listOf t.int) (l: l != [ 7 ]));
  doors = {
    d1 = genMerge.mkOptionType;
    d2 = genMerge.types.mkOptionType;
    raw = x: x;
  };
  served =
    eval: mods:
    let
      r = builtins.tryEval (
        let
          o = eval mods;
        in
        builtins.deepSeq o.config.loom o.config.loom
      );
    in
    if r.success then { value = r.value; } else null;
  gen = served (genMerge.evalModuleTree { });
  ref = served (modules: lib.evalModules { inherit modules; });
  declareGen = type: { options.loom = genMerge.mkOption { inherit type; }; };
  declareRef = type: { options.loom = lib.mkOption { inherit type; }; };
  # N − 1 gen declarations and the partner, partner last (`G…GP`) and first (`PG…G`)
  orders =
    n: partner:
    let
      gs = builtins.genList (_: genMerge.types.attrsOf inner) (n - 1);
    in
    [
      (gs ++ [ partner ])
      ([ partner ] ++ gs)
    ];
  twins =
    n: partner:
    let
      ps = builtins.genList (_: t.attrsOf inner) (n - 1);
    in
    [
      (ps ++ [ partner ])
      ([ partner ] ++ ps)
    ];
  ns = [
    2
    3
    4
  ];
  readGen =
    p: def:
    lib.concatMap (
      n:
      lib.concatMap (
        door:
        map (ts: gen (map declareGen ts ++ [ { loom = def; } ])) (orders n (doors.${door} (t.attrsOf p)))
      ) (builtins.attrNames doors)
    ) ns;
  readRef =
    p: def:
    lib.concatMap (
      n: map (ts: ref (map declareRef ts ++ [ { loom = def; } ])) (twins n (t.attrsOf p))
    ) ns;
  # 3 Ns × 3 doors × 2 orders
  cells = 18;
  value = {
    k = [
      [
        1
        2
      ]
      [ 3 ]
    ];
  };
in
{
  construct = [ "redeclared-option-accepts-only-what-every-declaration-accepts" ];
  check = asserts (
    readGen inner value == builtins.genList (_: { inherit value; }) cells
    && readRef inner value == builtins.genList (_: { inherit value; }) 6
    && readGen checked { k = [ [ 7 ] ]; } == builtins.genList (_: null) cells
    && readGen checked { k = [ [ 8 ] ]; } == builtins.genList (_: { value.k = [ [ 8 ] ]; }) cells
  );
}
