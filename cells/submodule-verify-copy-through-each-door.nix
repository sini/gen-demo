# `submodule-verify-copy-through-each-door` — den-hoag-d74w0. A gen `submodule` copied with a `verify`, alone and
# beside an ad-hoc check override, completed through `types.defineType` and `mkOptionType`, is used as an option's
# type, bare and as `attrsOf`'s element. Its `verify` reads the member (`v.a`, which the submodule defaults) and a
# relation across definitions (`a = 1` needs `b = 1`), so it holds of the merged value of a split and of no
# definition in it. Through each door the split is served at its merged value and a value whose merged form the
# `verify` rejects is refused by name; the override's own check, a per-definition predicate (ADR-0039,
# 2026-10-08), still refuses `a = 7`. Each door used to judge the `verify` per definition, refusing the split
# by the wrong type or aborting on the member it reads.
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
  q = v: if v.a != 1 || v.b == 1 then null else "a = 1 needs b = 1";
  notSeven = v: !(builtins.isAttrs v) || (v.a or 0) != 7;
  copies = X: p: o: [
    (X // { verify = p; })
    (X // { check = v: X.check v && o v; } // { verify = p; })
  ];
  doors = [
    t.defineType
    genMerge.mkOptionType
  ];
  judged =
    ty: w:
    served ty
      [
        (w { a = 1; })
        (w { b = 1; })
      ]
      (w {
        a = 1;
        b = 1;
      })
    && refused (read ty [ (w { a = 1; }) ]);
  overridden = ty: w: refused (read ty [ (w { a = 7; }) ]);
  through =
    X: p: o: w:
    let
      cs = copies X p o;
    in
    lib.all (door: lib.all (c: judged (door c) w) cs && overridden (door (lib.last cs)) w) doors;
  bare = through plain q notSeven (v: v);
  element =
    through (t.attrsOf plain) (v: lib.findFirst (e: e != null) null (map q (builtins.attrValues v)))
      (v: lib.all notSeven (builtins.attrValues v))
      (v: {
        k = v;
      });
in
{
  construct = [ "a-gen-submodule-verify-copy-through-each-door-judges-its-merged-value" ];
  check = asserts (bare && element);
}
