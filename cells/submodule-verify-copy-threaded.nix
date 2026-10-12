# `submodule-verify-copy-threaded` — den-hoag-jgr98. A gen `submodule` copied with a `verify`, alone and with an
# ad-hoc check override beside it, is used raw as an option's type, bare and as `attrsOf`'s element. Its `verify`
# judges the merged value: `{ a = 2; }` is served, and `{ b = 3; }`, whose `a` the submodule's own default sets
# to 1, is refused by name, as is a split whose definitions each leave `a` to that default. The copy used to be
# answered as a gen leaf, so its called fold refused every value ("does not evaluate the nested tree").
# Through `types.defineType` and `mkOptionType` the copy is also judged per definition (den-hoag-d74w0), so this
# cell states the raw record only.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  read =
    type: v:
    (genMerge.evalModuleTree { } (
      [ { options.bobbin = genMerge.mkOption { inherit type; }; } ] ++ map (d: { bobbin = d; }) v
    )).config.bobbin;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
  served =
    ty: v: want:
    let
      r = builtins.tryEval (builtins.deepSeq (read ty v) (read ty v));
    in
    r.success && r.value == want;
  plain = t.submodule {
    options.a = genMerge.mkOption {
      type = t.int;
      default = 1;
    };
    options.b = genMerge.mkOption {
      type = t.int;
      default = 0;
    };
  };
  notOne = v: if v.a != 1 then null else "a is 1";
  copies = X: p: [
    (X // { verify = p; })
    (X // { check = v: X.check v; } // { verify = p; })
  ];
  enforced =
    ty: w:
    served ty [ (w { a = 2; }) ] (w {
      a = 2;
      b = 0;
    })
    &&
      served ty
        [
          (w { a = 2; })
          (w { b = 3; })
        ]
        (w {
          a = 2;
          b = 3;
        })
    && refused (read ty [ (w { b = 3; }) ])
    && refused (
      read ty [
        (w { b = 3; })
        (w { })
      ]
    );
  bare = lib.all (c: enforced c (v: v)) (copies plain notOne);
  element =
    lib.all
      (
        c:
        enforced c (v: {
          k = v;
        })
      )
      (
        copies (t.attrsOf plain) (v: lib.findFirst (e: e != null) null (map notOne (builtins.attrValues v)))
      );
in
{
  construct = [ "a-gen-submodule-verify-copy-used-raw-judges-its-merged-value" ];
  check = asserts (bare && element);
}
