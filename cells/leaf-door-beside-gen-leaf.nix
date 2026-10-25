# `leaf-door-beside-gen-leaf` — a-nixpkgs-leaf-through-a-door-beside-gen-leaf-serves, den-hoag-io5ox.
# A nixpkgs leaf returned by either `mkOptionType` door states the relation it crossed with (`retainedRelation`), and
# a redeclaration beside gen's own leaf joins it as the record's raw form is joined, through gen's embedding of
# nixpkgs' `str`, `enum` and `number`. Before, the leaf relation read the door's return as a gen leaf of another name
# and refused the option where nixpkgs' `lib.evalModules` serves the same declarations. Each served value below
# equals nixpkgs' over nixpkgs' own twin; a value the door partner's own check rejects is refused, at two, three and
# four declarations in any order; a different leaf through the door stays refused.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  ft = lib.types;
  doors = [
    genMerge.mkOptionType
    t.mkOptionType
  ];
  decls =
    tag: types:
    lib.imap0 (i: type: {
      _file = "/demo/${tag}${toString i}.nix";
      options.x = lib.mkOption { inherit type; };
    }) types;
  gen = types: v: (genMerge.evalModuleTree { } (decls "g" types ++ [ { x = v; } ])).config.x;
  nixpkgs = types: v: (lib.evalModules { modules = decls "n" types ++ [ { x = v; } ]; }).config.x;
  attempt = e: builtins.tryEval (builtins.deepSeq e e);
  # gen's leaf beside the door's return of `p`, both orders and both doors, at nixpkgs' value over its own twin `n`
  twin =
    g: n: p: v:
    let
      want = attempt (nixpkgs [ n p ] v);
    in
    want.success
    && builtins.all (
      door: attempt (gen [ g (door p) ] v) == want && attempt (gen [ (door p) g ] v) == want
    ) doors;
  refused =
    g: p: v:
    builtins.all (
      door: !(attempt (gen [ g (door p) ] v)).success && !(attempt (gen [ (door p) g ] v)).success
    ) doors;
in
{
  construct = [ "a-nixpkgs-leaf-through-a-door-beside-gen-leaf-serves" ];
  check = asserts (
    twin t.str ft.str ft.str "s"
    && twin (t.enum "e" [ "a" ]) (ft.enum [ "a" ]) (ft.enum [ "a" ]) "a"
    # the enum-union law: the partner's own member is served
    && twin (t.enum "e" [ "a" ]) (ft.enum [ "a" ]) (ft.enum [ "b" ]) "b"
    && twin t.number ft.number ft.number 1.5
    # one level down, the door's return under gen's `listOf`
    && builtins.all (
      door:
      attempt (gen [ (t.listOf t.str) (t.listOf (door ft.str)) ] [ "s" ])
      == attempt (nixpkgs [ (ft.listOf ft.str) (ft.listOf ft.str) ] [ "s" ])
    ) doors
    # the door partner's own check is kept where nixpkgs drops it
    && refused t.str (ft.addCheck ft.str (s: s != "bad")) "bad"
    && refused t.number (ft.addCheck ft.number (x: x > 0)) (-1)
    # three and four declarations: the checked partner's check is kept at every step, whatever follows it
    && builtins.all (
      door:
      let
        C = door (ft.addCheck ft.str (s: s != "bad"));
        D = door (ft.addCheck ft.str (s: s != "worse"));
        N = door ft.str;
      in
      !(attempt (gen [ C N t.str ] "bad")).success
      && !(attempt (gen [ C t.str N ] "bad")).success
      && !(attempt (gen [ C D N ] "bad")).success
      && !(attempt (gen [ t.str C D N ] "bad")).success
      &&
        attempt (gen [ C N t.str ] "s") == attempt (
          nixpkgs [
            (ft.addCheck ft.str (s: s != "bad"))
            ft.str
            ft.str
          ] "s"
        )
    ) doors
    # control: a different leaf through the door stays refused
    && refused t.str ft.int "s"
  );
}
