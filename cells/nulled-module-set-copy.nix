# `nulled-module-set-copy` — den-hoag-y4w78, den-hoag-b9fl0. A `//` copy stating `getSubModules = null` contributes no
# module set of its own: nixpkgs reads a declaration's module set off its `getSubModules` alone. Where no declaration of
# an option states a set, nixpkgs keeps the join of the copies' functors (`fixupOptionType`, nixpkgs d17afff), which
# mounts the sets the copies carry, in union; a declaration stating a set mounts only the stated sets. So a copy
# declared twice is served, as `lib.evalModules` serves it, and declared once or beside its plain twin it reads the
# value nixpkgs reads. The copy is of a gen-merge `submodule` and of a nixpkgs one, at an option's root, inside a gen
# `attrsOf`, under a gen `nullOr`, and through the published `defineType`. A copy of a CHECKED module set declared twice
# is served what its check accepts and refused what it rejects, where nixpkgs' join drops the check.
{
  asserts,
  genMerge,
  lib,
}:
let
  # keyed: the same module declared twice is one module, as nixpkgs dedups it
  sub =
    types: mk: i:
    types.submodule {
      key = "nulled-module-set-copy-${toString i}";
      options."a${toString i}" = mk {
        type = types.int;
        default = 0;
      };
    };
  foreignSub =
    _types: _mk: i:
    lib.types.submodule {
      key = "nulled-module-set-copy-foreign-${toString i}";
      options."a${toString i}" = lib.mkOption {
        type = lib.types.int;
        default = 0;
      };
    };
  nulled = t: t // { getSubModules = null; };
  # each shape, as a function of a vocabulary (gen-merge's or nixpkgs'), its option builder, a door, the copy and the
  # declaration's module set (`same` = 0 for every declaration, else its own index)
  shapes = {
    root =
      s: types: mk: _door: c: i:
      c (s types mk i);
    element =
      s: types: mk: _door: c: i:
      types.attrsOf (c (s types mk i));
    container =
      s: types: mk: _door: c: i:
      types.attrsOf (c (types.nullOr (s types mk i)));
    door =
      s: types: mk: door: c: i:
      types.attrsOf (door (c (s types mk i)));
  };
  at = shape: v: if shape == "root" then v else { k = v; };
  read =
    eval: types: mk: door: s: shape: same: copies: v:
    let
      r = builtins.tryEval (
        let
          x =
            (eval (
              lib.imap0 (i: c: {
                options.x = mk { type = shapes.${shape} s types mk door c (if same then 0 else i); };
              }) copies
              ++ [ { x = at shape v; } ]
            )).config.x;
        in
        builtins.deepSeq x x
      );
    in
    if r.success then r.value else null;
  gen = read (genMerge.evalModuleTree { }) genMerge.types genMerge.mkOption genMerge.types.defineType;
  ref = read (modules: lib.evalModules { inherit modules; }) lib.types lib.mkOption (t: t);
  plain = t: t;
  arrangements = {
    twice = [
      nulled
      nulled
    ];
    thrice = [
      nulled
      nulled
      nulled
    ];
    once = [ nulled ];
    copyFirst = [
      nulled
      plain
    ];
    plainFirst = [
      plain
      nulled
    ];
  };
  # parity: gen's engine reads what nixpkgs' reads, every shape, both module sets, every arrangement; every one is served
  parity =
    lib.all
      (
        s:
        lib.all (
          shape:
          lib.all (
            a:
            let
              g = gen s shape true arrangements.${a} { a0 = 1; };
            in
            g == ref s shape true arrangements.${a} { a0 = 1; } && g != null
          ) (builtins.attrNames arrangements)
        ) (builtins.attrNames shapes)
      )
      [
        sub
        foreignSub
      ];
  # the union law, hand-derived, defining nothing: the served keys are the mounted set
  union =
    lib.all
      (
        s:
        gen s "root" false [ nulled nulled ] { } == {
          a0 = 0;
          a1 = 0;
        }
        && gen s "root" false [ nulled nulled plain ] { } == { a2 = 0; }
        &&
          ref s "root" false [ nulled nulled ] { } == {
            a0 = 0;
            a1 = 0;
          }
      )
      [
        sub
        foreignSub
      ];
  # the check oracle: a checked set nulled and declared twice serves what its check accepts and refuses what it rejects
  p = v: !(v ? a0) || v.a0 != 2;
  checked =
    lib.all
      (
        s:
        let
          c = t: lib.types.addCheck t p // { getSubModules = null; };
        in
        gen s "root" true [ c c ] { a0 = 1; } == {
          a0 = 1;
        }
        && gen s "root" true [ c c ] { a0 = 2; } == null
      )
      [
        sub
        foreignSub
      ];
in
{
  construct = [ "a-nulled-module-set-copy-contributes-no-modules" ];
  check = asserts (parity && union && checked);
}
