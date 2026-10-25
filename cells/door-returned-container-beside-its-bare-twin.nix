# `door-returned-container-beside-its-bare-twin` — a-door-return-redeclared-beside-its-bare-type-serves, den-hoag-bkmiz.
# A container returned by the `mkOptionType` door states the relation it crossed with (`retainedRelation`), and a
# redeclaration beside the bare type joins in that relation as the record's raw form does. Before, an `attrsOf`,
# `lazyAttrsOf` or `deferredModule` door return was read as gen's own row-free partner, offered no element, and the
# option was refused for every element where nixpkgs' `lib.evalModules` serves the same two declarations. Each served
# value below equals nixpkgs' over the SAME declared types; a value the door's element check rejects is refused by
# the meet; a raw `listOf` whose payload states a parameter beside its element is still refused, in both orders.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  ft = lib.types;
  door = t.mkOptionType;
  sub = ft.submodule { options.a = lib.mkOption { type = ft.int; }; };
  odd = v: !(builtins.isAttrs v) || (v.a or 0) != 1;
  decls =
    tag: types:
    lib.imap0 (i: type: {
      _file = "/demo/${tag}${toString i}.nix";
      options.x = lib.mkOption { inherit type; };
    }) types;
  gen = types: v: (genMerge.evalModuleTree { } (decls "g" types ++ [ { x = v; } ])).config.x;
  nixpkgs = types: v: (lib.evalModules { modules = decls "n" types ++ [ { x = v; } ]; }).config.x;
  attempt = e: builtins.tryEval (builtins.deepSeq e e);
  # served in both orders, at nixpkgs' value over the same declarations
  twin =
    bare: returned: v:
    let
      want = attempt (nixpkgs [ bare returned ] v);
    in
    want.success
    && attempt (gen [ bare returned ] v) == want
    && attempt (gen [ returned bare ] v) == want;
  refused = types: v: !(attempt (gen types v)).success;
  lazyList = ft.mkOptionType {
    name = "listOf";
    check = builtins.isList;
    merge = (ft.listOf ft.int).merge;
    functor = {
      name = "listOf";
      wrapped = null;
      payload = {
        elemType = ft.int;
        lazy = true;
      };
      type = _: lazyList;
      binOp =
        a: b:
        let
          m = a.elemType.typeMerge b.elemType.functor;
        in
        if m == null then
          null
        else
          {
            elemType = m;
            lazy = a.lazy;
          };
    };
    nestedTypes.elemType = ft.int;
  };
in
{
  construct = [ "a-door-return-redeclared-beside-its-bare-type-serves" ];
  check = asserts (
    # gen's own containers through the door, any element
    twin (t.attrsOf ft.int) (door (t.attrsOf ft.int)) { k = 2; }
    && twin (t.lazyAttrsOf ft.str) (door (t.lazyAttrsOf ft.str)) { k = "s"; }
    && twin (t.attrsOf sub) (door (t.attrsOf (ft.addCheck sub odd))) { k.a = 2; }
    && twin t.deferredModule (door t.deferredModule) { }
    # one level down, under a container the door does not wrap
    && twin (t.listOf (t.attrsOf ft.int)) (t.listOf (door (t.attrsOf ft.int))) [ { k = 2; } ]
    # nixpkgs' records through the door, its own parameters included
    && twin (t.attrsOf ft.int) (door (ft.attrsOf ft.int)) { k = 2; }
    && twin (t.attrsOf ft.int) (door (
      ft.attrsWith {
        elemType = ft.int;
        placeholder = "id";
      }
    )) { k = 2; }
    # the meet: the door's element check is kept where nixpkgs drops it
    && refused [ (t.attrsOf sub) (door (t.attrsOf (ft.addCheck sub odd))) ] { k.a = 1; }
    && refused [ (door (t.attrsOf (ft.addCheck sub odd))) (t.attrsOf sub) ] { k.a = 1; }
    # controls: a different parameter, and a raw partner stating more than its element, stay refused
    && refused [ (t.lazyAttrsOf ft.int) (door (t.attrsOf ft.int)) ] { k = 2; }
    && refused [ (t.listOf ft.int) lazyList ] [ 2 ]
    && refused [ lazyList (t.listOf ft.int) ] [ 2 ]
  );
}
