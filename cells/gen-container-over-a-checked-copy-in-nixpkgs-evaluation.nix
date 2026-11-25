# `a-gen-container-over-a-checked-copy-is-enforced-in-nixpkgs-evaluation` — den-hoag-umpfd. Three copies of a
# submodule with a check laid on (gen's with its check's functor replaced, nixpkgs' `addCheck` over gen's, and
# nixpkgs' `addCheck` over nixpkgs' own submodule), each below gen `attrsOf`, `nullOr` and `listOf`, declared one to four
# times in nixpkgs' `lib.evalModules`. `{ a = 1; }` and `{ a = 3; }` are served as written and `{ a = 2; }` is refused
# at every count. nixpkgs' fixup rebuilds a gen container over its element, and a copy's rebuild is its base's, so the
# rebuilt container served the value the copy's check rejects.
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
  # three copies of a submodule with a check laid on: gen's, its check's functor replaced; nixpkgs' addCheck over
  # gen's; nixpkgs' addCheck over nixpkgs' own submodule
  copies = {
    rewritten = sub // {
      check = sub.check // {
        __functor = _: v: sub.check v && notTwo v;
      };
    };
    addCheck = lib.types.addCheck sub notTwo;
    foreign = lib.types.addCheck (lib.types.submodule {
      options.a = lib.mkOption { type = lib.types.int; };
    }) notTwo;
  };
  # gen containers whose rebuild re-carries the copy
  containers = {
    attrsOf = {
      t = T.attrsOf;
      v = x: { k = x; };
    };
    nullOr = {
      t = T.nullOr;
      v = x: x;
    };
    listOf = {
      t = T.listOf;
      v = x: [ x ];
    };
  };
  # declared n times in nixpkgs' `lib.evalModules`
  read =
    n: r: w: a:
    let
      x = builtins.tryEval (
        let
          o =
            (lib.evalModules {
              modules = builtins.genList (_: { options.o = lib.mkOption { type = w.t r; }; }) n ++ [
                { config.o = w.v { inherit a; }; }
              ];
            }).config.o;
        in
        builtins.deepSeq o o
      );
    in
    if x.success then x.value else false;
  rows =
    a:
    lib.concatMapAttrs (
      rn: r:
      lib.concatMapAttrs (
        wn: w:
        lib.listToAttrs (
          map
            (n: {
              name = "${rn}-${wn}-${toString n}";
              value = read n r w a;
            })
            [
              1
              2
              3
              4
            ]
        )
      ) containers
    ) copies;
  served =
    a:
    lib.concatMapAttrs (
      rn: _:
      lib.concatMapAttrs (
        wn: w:
        lib.listToAttrs (
          map
            (n: {
              name = "${rn}-${wn}-${toString n}";
              value = w.v { inherit a; };
            })
            [
              1
              2
              3
              4
            ]
        )
      ) containers
    ) copies;
in
{
  construct = [ "a-gen-container-over-a-checked-copy-is-enforced-in-nixpkgs-evaluation" ];
  check = asserts (
    rows 1 == served 1
    && rows 3 == served 3
    && builtins.all (v: v == false) (builtins.attrValues (rows 2))
  );
}
