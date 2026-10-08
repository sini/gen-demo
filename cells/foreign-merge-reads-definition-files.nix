# `foreign-merge-reads-definition-files` — foreign-merge-is-handed-nixpkgs-definition-records,
# den-hoag-j5gfg (ADR-0039, the serve half; ADR-0025 item 1). A nixpkgs `coercedTo` over an
# overridden `listOf (lazyAttrsOf …)` of a gen nested type threads its chain, and the overriding
# merge is handed the definition records nixpkgs hands it, `{ file; value; }`. A merge that sorts
# its definitions by `file`, or groups them with `file` as an attribute name, reads each element as
# `lib.evalModules` does, where each aborted uncatchably on an attrset `file`.

{
  asserts,
  genMerge,
  lib,
}:

let
  np = lib.types;
  # the merge, overridden to rewrite its definitions by `pre` (each element gains a key naming what
  # the merge read of its definition's `file`)
  over =
    pre: a:
    a
    // {
      merge = {
        __functor =
          _: loc: defs:
          a.merge loc (pre defs);
        v2 =
          { loc, defs }:
          a.merge.v2 {
            inherit loc;
            defs = pre defs;
          };
      };
      substSubModules = m: over pre (a.substSubModules m);
    };
  tagWith =
    f: defs:
    map (
      d:
      d
      // {
        value = map (
          x:
          x
          // {
            ${f defs d} = {
              k.a = 0;
            };
          }
        ) d.value;
      }
    ) defs;
  bySort = defs: tagWith (_: d: d.file) (builtins.sort (a: b: a.file < b.file) defs);
  byGroup = tagWith (
    defs: d: "g" + toString (builtins.length (builtins.groupBy (x: x.file) defs).${d.file})
  );
  # one fixture, two engines: gen-merge's `evalModuleTree` with a gen element, and `lib.evalModules`
  # with nixpkgs' own
  run =
    gen: pre:
    let
      T = if gen then genMerge.types else np;
      mkOption = if gen then genMerge.mkOption else lib.mkOption;
      sub = T.submodule {
        options.a = mkOption {
          type = T.int;
          default = 0;
        };
      };
      type = np.coercedTo np.str (_: throw "unused") (
        over pre (np.listOf (np.lazyAttrsOf (T.attrsOf sub)))
      );
      modules = [
        { options.s = mkOption { inherit type; }; }
        {
          _file = "zz";
          config.s = [ { j.k.a = 1; } ];
        }
        {
          _file = "aa";
          config.s = [ { j.k.a = 2; } ];
        }
      ];
      cfg =
        if gen then
          (genMerge.evalModuleTree { } modules).config
        else
          (lib.evalModules { inherit modules; }).config;
    in
    map (e: {
      inherit (e.j.k) a;
      keys = builtins.attrNames e;
    }) cfg.s;
  same = pre: run true pre == run false pre;
in
{
  construct = [ "foreign-merge-is-handed-nixpkgs-definition-records" ];
  check = asserts (
    same bySort
    && same byGroup
    # the reference reads the files it was handed, so the comparison is not vacuous
    &&
      run false bySort == [
        {
          a = 2;
          keys = [
            "aa"
            "j"
          ];
        }
        {
          a = 1;
          keys = [
            "j"
            "zz"
          ];
        }
      ]
  );
}
