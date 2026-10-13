# `module-set-verify-copy-in-nixpkgs-evaluation` — den-hoag-olrmz. A gen `submodule`, and a gen `attrsOf` of one,
# copied with a `verify` that reads a member and completed through `types.defineType` or `mkOptionType` (once, or
# with the door's output re-entered through `mkOptionType`), is declared in nixpkgs' own `lib.evalModules`. nixpkgs
# reads the record's `merge` and the rebuild it calls at the option's fixup, so the copy states its `verify` there:
# an accepted value is served as nixpkgs' `addCheck` twin serves it, and a value the `verify` rejects is refused.
# nixpkgs' evaluation used to serve the rejected value, because the rebuild re-derived the base without the `verify`.
{
  asserts,
  genMerge,
  lib,
}:
let
  M = genMerge;
  T = M.types;
  tuck = T.submodule {
    options.pin = M.mkOption {
      type = T.int;
      default = 1;
    };
    options.stitch = M.mkOption {
      type = T.int;
      default = 0;
    };
  };
  npTuck = lib.types.submodule {
    options.pin = lib.mkOption {
      type = lib.types.int;
      default = 1;
    };
    options.stitch = lib.mkOption {
      type = lib.types.int;
      default = 0;
    };
  };
  notTwo = v: !(builtins.isAttrs v) || (v.pin or 1) != 2;
  verify = p: v: if p v then null else "pin must not be 2";
  allNotTwo = v: builtins.all notTwo (builtins.attrValues v);
  read =
    ty: d:
    let
      x =
        (lib.evalModules {
          modules = [
            { options.hem = lib.mkOption { type = ty; }; }
            { config.hem = d; }
          ];
        }).config.hem;
      r = builtins.tryEval (builtins.deepSeq x x);
    in
    if r.success then r.value else "REFUSED";
  twin =
    ty: p: d:
    read (lib.types.addCheck ty p) d;
  doors = {
    defineType = T.defineType;
    mkOptionType = M.mkOptionType;
    redoored = c: M.mkOptionType (T.defineType c);
  };
  judged =
    base: npBase: p: w:
    lib.mapAttrs (_: door: {
      ok = read (door (base // { verify = verify p; })) (w {
        pin = 3;
      });
      bad = read (door (base // { verify = verify p; })) (w {
        pin = 2;
      });
    }) doors == lib.mapAttrs (_: _: {
      ok = twin npBase p (w {
        pin = 3;
      });
      bad = "REFUSED";
    }) doors;
in
{
  construct = [ "a-gen-module-set-verify-copy-is-enforced-in-nixpkgs-evaluation" ];
  check = asserts (
    judged tuck npTuck notTwo (v: v)
    && judged (T.attrsOf tuck) (lib.types.attrsOf npTuck) allNotTwo (v: {
      k = v;
    })
  );
}
