# `cyclic-type-spine` — C163, den-hoag-iaram. A gen-merge type cycled through containers alone,
# `bobbin = nullOr (listOf bobbin)`, is contractive: its values check and merge. Mounted through gen's
# own `evalModuleTree` it serves `[ null [ null ] ]`. Mounted through nixpkgs' `lib.evalModules`,
# whose `fixupOptionType` reads the type's `getSubModules` on every option, the read refuses by name
# (the element chain forwards past the walk's fuel), a refusal `tryEval` catches, where nixpkgs' own
# twin `nullOr (listOf bobbin)` aborts uncatchably. The control is the same cycle closed through a
# union, `oneOf [ int (listOf spool) ]`, whose union answers for itself: nixpkgs serves it.

{
  asserts,
  genMerge,
  lib,
}:

let
  G = genMerge.types;
  bobbin = G.nullOr (G.listOf bobbin);
  spool = G.nullOr (
    G.oneOf [
      G.int
      (G.listOf spool)
    ]
  );
  defs = [
    null
    [ null ]
  ];
  viaGen =
    type:
    (genMerge.evalModuleTree { } [
      { options.thread = genMerge.mkOption { inherit type; }; }
      { thread = defs; }
    ]).config.thread;
  viaNixpkgs =
    type:
    (lib.evalModules {
      modules = [
        { options.thread = lib.mkOption { inherit type; }; }
        { config.thread = defs; }
      ];
    }).config.thread;
  refuses = x: !(builtins.tryEval (builtins.deepSeq x null)).success;
in

{
  construct = [ "C163" ];
  check = asserts (
    viaGen bobbin == defs
    && refuses (viaNixpkgs bobbin)
    # control: the union-closed twin answers its spine, so nixpkgs serves it
    && viaNixpkgs spool == defs
  );
}
