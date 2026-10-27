# `door-returned-container-beside-its-bare-twin` — a-door-return-redeclared-beside-its-bare-type-serves, den-hoag-bkmiz.
# A container returned by the `mkOptionType` door whose stated relation gen cannot read whole (an `attrsWith` or
# `deferredModuleWith` payload, parameters beside the element) is joined in that relation, so a redeclaration beside
# the bare type serves nixpkgs' value where it was refused. Two things stay as nixpkgs has them: a door return whose
# own relation answers the pair with an ad-hoc `type // { check }` override, at its top or under any type it carries
# (an `either` alternative, an `attrTag` tag), is not joined so, and is refused where it decides the pair, as nixpkgs refuses
# it; and a door return gen reads whole (a
# `listOf` whose payload is its element) keeps gen's own relation, so a partner whose functor answers differently away
# from its own parameters is served at three declarations as nixpkgs serves it.
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
  decls = tag: types: lib.imap0 (i: type: { _file = "/demo/${tag}${toString i}.nix"; options.x = lib.mkOption { inherit type; }; }) types;
  gen = types: v: (genMerge.evalModuleTree { } (decls "g" types ++ [ { x = v; } ])).config.x;
  nixpkgs = types: v: (lib.evalModules { modules = decls "n" types ++ [ { x = v; } ]; }).config.x;
  attempt = e: builtins.tryEval (builtins.deepSeq e e);
  # served in both orders, at nixpkgs' value over the same declarations
  twin =
    bare: returned: v:
    let
      want = attempt (nixpkgs [ bare returned ] v);
    in
    want.success && attempt (gen [ bare returned ] v) == want && attempt (gen [ returned bare ] v) == want;
  # gen's engine over `types` reads what nixpkgs' reads over `twins`, served or refused
  same = types: twins: v: attempt (gen types v) == attempt (nixpkgs twins v);
  refused = types: v: !(attempt (gen types v)).success;
  # an `attrsWith` record whose `check` is an ad-hoc override, its functor rebuilding the override at every payload
  overAttrs = ft.mkOptionType {
    name = "attrsOf";
    check = builtins.isAttrs;
    merge = (ft.attrsOf ft.int).merge;
    functor = {
      name = "attrsWith";
      wrapped = null;
      payload = { elemType = ft.int; lazy = false; placeholder = "name"; extra = 1; };
      type = _: overAttrs;
      binOp = a: b: let m = a.elemType.typeMerge b.elemType.functor; in if m == null then null else a // { elemType = m; };
    };
    nestedTypes.elemType = ft.int;
  };
  short = v: builtins.isList v && builtins.length v < 2;
  # a `listOf int` with an ad-hoc check, its functor rebuilding the override, under `either` in an `attrsOf`
  shortList = ft.mkOptionType {
    name = "listOf";
    check = short;
    inherit (ft.listOf ft.int) merge;
    functor = {
      name = "listOf";
      wrapped = null;
      payload.elemType = ft.int;
      type = _: shortList;
      binOp = a: b: let m = a.elemType.typeMerge b.elemType.functor; in if m == null then null else { elemType = m; };
    };
    nestedTypes.elemType = ft.int;
  };
  eitherL = ft.either (ft.listOf ft.int) ft.str;
  overEither = ft.attrsOf (ft.either shortList ft.str);
  tagged = t: ft.attrTag { a = lib.mkOption { type = t; }; b = lib.mkOption { type = ft.str; }; };
  overTag = ft.attrsOf (tagged shortList);
  # a `listOf (enum [ "a" ])` with an ad-hoc check, its functor rebuilding the override at its own payload only
  hzP =
    let
      over = elem: ft.mkOptionType {
        inherit (ft.listOf elem) name merge;
        check = short;
        functor = (ft.listOf elem).functor // {
          type = q: if (q.elemType.functor.payload.values or null) == [ "a" ] then over q.elemType else ft.listOf q.elemType;
        };
        nestedTypes.elemType = elem;
      };
    in
    over (ft.enum [ "a" ]);
  lazyList = ft.mkOptionType {
    name = "listOf";
    check = builtins.isList;
    merge = (ft.listOf ft.int).merge;
    functor = {
      name = "listOf";
      wrapped = null;
      payload = { elemType = ft.int; lazy = true; };
      type = _: lazyList;
      binOp = a: b: let m = a.elemType.typeMerge b.elemType.functor; in if m == null then null else { elemType = m; lazy = a.lazy; };
    };
    nestedTypes.elemType = ft.int;
  };
  # an `attrsWith` over `enum [ "a" ]` with an ad-hoc check, its functor answering the override at every payload but
  # its own: the override is the join at a widened payload, never the record itself
  hzR =
    let
      own = q: (q.elemType.functor.payload.values or null) == [ "a" ];
      over = elem: ft.mkOptionType {
        inherit (ft.attrsOf elem) name merge;
        check = v: builtins.isAttrs v && builtins.length (builtins.attrNames v) < 2;
        functor = (ft.attrsOf elem).functor // { type = q: if own q then ft.attrsWith q else over q.elemType; };
        nestedTypes.elemType = elem;
      };
    in
    over (ft.enum [ "a" ]);
  aI = t.attrsOf ft.int;
  lB = t.listOf (ft.enum [ "b" ]);
in
{
  construct = [ "a-door-return-redeclared-beside-its-bare-type-serves" ];
  check = asserts (
    # gen's own containers through the door, any element
    twin aI (door aI) { k = 2; }
    && twin (t.lazyAttrsOf ft.str) (door (t.lazyAttrsOf ft.str)) { k = "s"; }
    && twin (t.attrsOf sub) (door (t.attrsOf (ft.addCheck sub odd))) { k.a = 2; }
    && twin t.deferredModule (door t.deferredModule) { }
    # one level down, under a container the door does not wrap
    && twin (t.listOf aI) (t.listOf (door aI)) [ { k = 2; } ]
    # nixpkgs' records through the door, its own parameters included
    && twin aI (door (ft.attrsOf ft.int)) { k = 2; }
    && twin aI (door (ft.attrsWith { elemType = ft.int; placeholder = "id"; })) { k = 2; }
    # the meet: the door's element check is kept where nixpkgs drops it
    && refused [ (t.attrsOf sub) (door (t.attrsOf (ft.addCheck sub odd))) ] { k.a = 1; }
    && refused [ (door (t.attrsOf (ft.addCheck sub odd))) (t.attrsOf sub) ] { k.a = 1; }
    # an override join: refused where the door decides it (declared later), as nixpkgs refuses it
    && same [ aI (door overAttrs) ] [ (ft.attrsOf ft.int) overAttrs ] { k = 2; }
    && refused [ aI (door overAttrs) ] { k = 2; }
    && same [ (t.attrsOf (ft.enum [ "b" ])) (door hzR) ] [ (ft.attrsOf (ft.enum [ "b" ])) hzR ] { k = "a"; }
    && same [ (t.attrsOf eitherL) (door overEither) ] [ (ft.attrsOf eitherL) overEither ] { k = [ 2 ]; }
    && refused [ (t.attrsOf eitherL) (door overEither) ] { k = [ 2 ]; }
    && same [ (t.attrsOf (tagged (ft.listOf ft.int))) (door overTag) ] [ (ft.attrsOf (tagged (ft.listOf ft.int))) overTag ] { k.a = [ 2 ]; }
    && refused [ (t.attrsOf (tagged (ft.listOf ft.int))) (door overTag) ] { k.a = [ 2 ]; }
    # a payload-dependent partner gen reads whole, at three declarations, as nixpkgs serves it
    && same [ lB (door hzP) lB ] [ (ft.listOf (ft.enum [ "b" ])) hzP (ft.listOf (ft.enum [ "b" ])) ] [ "a" "b" ]
    && !(refused [ lB (door hzP) lB ] [ "a" "b" ])
    # controls: a different parameter, and a raw partner stating more than its element, stay refused
    && refused [ (t.lazyAttrsOf ft.int) (door aI) ] { k = 2; }
    && refused [ (t.listOf ft.int) lazyList ] [ 2 ]
    && refused [ lazyList (t.listOf ft.int) ] [ 2 ]
  );
}
