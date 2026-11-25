# `a-checked-record-declared-three-times-is-served` — den-hoag-7fb0k. One gen submodule with a check laid on, in both
# spellings (its check's functor replaced, and nixpkgs' `addCheck`), declared three and four times, bare and below gen
# `attrsOf`, in gen's `evalModuleTree`. `{ a = 1; }` is served as written, as nixpkgs' `lib.evalModules` serves it, and
# `{ a = 2; }` is refused at every count. Before, from three declarations the one-value step compared the module set's
# `emptyValue` (the set evaluated over no definitions), forced its options, and refused the valid value with "the
# option `a' is used but not defined".
{
  asserts,
  genMerge,
  lib,
}:
let
  T = genMerge.types;
  sub = T.submodule {
    options.a = genMerge.mkOption { type = T.int; };
  };
  notTwo = v: !(v ? a && v.a == 2);
  # the two rewritten-check spellings of one gen submodule: its check's functor replaced, and nixpkgs' addCheck
  records = {
    rewritten = sub // {
      check = sub.check // {
        __functor = _: v: sub.check v && notTwo v;
      };
    };
    addCheck = lib.types.addCheck sub notTwo;
  };
  wraps = {
    bare = {
      t = x: x;
      v = x: x;
    };
    keyed = {
      t = T.attrsOf;
      v = x: { k = x; };
    };
  };
  read =
    ev: mk: n: r: w: a:
    let
      x = builtins.tryEval (
        let
          o =
            (ev (
              builtins.genList (_: { options.o = mk { type = w.t r; }; }) n
              ++ [ { config.o = w.v { inherit a; }; } ]
            )).config.o;
        in
        builtins.deepSeq o o
      );
    in
    if x.success then x.value else false;
  rows =
    ev: mk: a:
    lib.concatMapAttrs (
      rn: r:
      lib.concatMapAttrs (wn: w: {
        "${rn}-${wn}-3" = read ev mk 3 r w a;
        "${rn}-${wn}-4" = read ev mk 4 r w a;
      }) wraps
    ) records;
  gen = rows (genMerge.evalModuleTree { }) genMerge.mkOption;
  nixpkgs = rows (modules: lib.evalModules { inherit modules; }) lib.mkOption;
in
{
  construct = [ "a-checked-record-declared-three-times-is-served" ];
  check = asserts (
    gen 1 == nixpkgs 1
    &&
      gen 1 == {
        rewritten-bare-3 = {
          a = 1;
        };
        rewritten-bare-4 = {
          a = 1;
        };
        rewritten-keyed-3 = {
          k.a = 1;
        };
        rewritten-keyed-4 = {
          k.a = 1;
        };
        addCheck-bare-3 = {
          a = 1;
        };
        addCheck-bare-4 = {
          a = 1;
        };
        addCheck-keyed-3 = {
          k.a = 1;
        };
        addCheck-keyed-4 = {
          k.a = 1;
        };
      }
    && builtins.all (v: v == false) (builtins.attrValues (gen 2))
  );
}
