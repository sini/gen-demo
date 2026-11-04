# `door-return-declared-before-a-gen-container-keeps-its-check` — redeclared-option-accepts-only-what-every-declaration-accepts, den-hoag-ghvsu.
# A nixpkgs `addCheck (listOf (enum ["a"]))` returned by either door, declared beside gen's `listOf (enum ["b"])`.
# Under nixpkgs' fold, with the door's return declared first, gen's container is asked to merge the return's functor;
# the return names itself as the declaration there, so its check is still owed and `["a" "a"]` is refused in both
# orders, in gen's engine and in nixpkgs'. A value the return's own parameters do not reach (`["a" "b"]`, outside
# `enum ["a"]`) is served, as nixpkgs serves it.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  short = v: builtins.isList v && builtins.length v < 2;
  partner = ft.addCheck (ft.listOf (ft.enum [ "a" ])) short;
  stock = genMerge.types.listOf (ft.enum [ "b" ]);
  decls = types: map (type: { options.x = lib.mkOption { inherit type; }; }) types;
  gen = types: v: (genMerge.evalModuleTree { } (decls types ++ [ { x = v; } ])).config.x;
  nixpkgs = types: v: (lib.evalModules { modules = decls types ++ [ { x = v; } ]; }).config.x;
  attempt = e: builtins.tryEval (builtins.deepSeq e e);
  # every door, engine and order
  each =
    p:
    builtins.all
      (
        door:
        builtins.all
          (
            engine:
            builtins.all (types: p (engine types)) [
              [
                (door partner)
                stock
              ]
              [
                stock
                (door partner)
              ]
            ]
          )
          [
            gen
            nixpkgs
          ]
      )
      [
        genMerge.mkOptionType
        genMerge.types.mkOptionType
      ];
in
{
  construct = [ "redeclared-option-accepts-only-what-every-declaration-accepts" ];
  check = asserts (
    each (
      read:
      !(attempt (read [
        "a"
        "a"
      ])).success
    )
    && each (read: attempt (read [ "a" ]) == attempt [ "a" ])
    && each (
      read:
      attempt (read [
        "a"
        "b"
      ]) == attempt [
        "a"
        "b"
      ]
    )
  );
}
