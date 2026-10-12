# `attrtag-tag-check` — an-attrtag-tags-check-is-enforced, den-hoag-8pjrq (owner-ruled 2026-10-10, P2 arm (F), M half).
# A check on a nixpkgs `attrTag` TAG's type is enforced in gen's engine. gen's engine calls `attrTag`'s own merge
# (`binOp` -> `mergeOptionDecls`) and its rebuild (`substSubModules`), which drop the tag's check. The cell covers
# `np.addCheck` and an ad-hoc `// { check }` override over a nixpkgs `submodule`, and `np.addCheck` over a leaf.
# Each is read raw and through `types.defineType` (and the module-set forms through `mkOptionType`); declared alone, twice, and beside the plain tag
# in either order; and below a nixpkgs `listOf` and a gen `attrsOf`. A value the check admits reads as nixpkgs reads it,
# and a value it rejects is refused by name. gen-merge used to serve the rejected value silently.
# Each refusal stands beside its passing twin, so a fold refusing everything cannot pass, and neither can one serving
# everything.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  gt = genMerge.types;
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.bobbin = genMerge.mkOption { inherit type; }; }) types ++ [ { bobbin = v; } ]
    )).config.bobbin;
  attempt = types: v: builtins.tryEval (builtins.deepSeq (read types v) (read types v));
  refused = types: v: !(attempt types v).success;
  served =
    types: v:
    let
      r = attempt types v;
    in
    r.success && r.value == v;
  plain = ft.submodule { options.warp = lib.mkOption { type = ft.int; }; };
  tagOf = t: ft.attrTag { weft = lib.mkOption { type = t; }; };
  forms = [
    {
      checked = ft.addCheck plain (v: v.warp != 5);
      inherit plain;
      ok.weft.warp = 2;
      bad.weft.warp = 5;
    }
    {
      checked = plain // {
        check = v: plain.check v && v.warp != 5;
      };
      inherit plain;
      ok.weft.warp = 2;
      bad.weft.warp = 5;
      # below a gen container this form refuses the value it admits, a separate row
      genContainer = false;
    }
    {
      checked = ft.addCheck ft.int (v: v != 5);
      plain = ft.int;
      ok.weft = 2;
      bad.weft = 5;
    }
  ];
  positions =
    door: f:
    [
      {
        types = [ (door (tagOf f.checked)) ];
        inherit (f) ok bad;
      }
      {
        types = [
          (door (tagOf f.checked))
          (door (tagOf f.checked))
        ];
        inherit (f) ok bad;
      }
      {
        types = [
          (tagOf f.plain)
          (door (tagOf f.checked))
        ];
        inherit (f) ok bad;
      }
      {
        types = [
          (door (tagOf f.checked))
          (tagOf f.plain)
        ];
        inherit (f) ok bad;
      }
      {
        types = [ (door (ft.listOf (tagOf f.checked))) ];
        ok = [ f.ok ];
        bad = [ f.bad ];
      }
    ]
    ++ lib.optional (f.genContainer or true) {
      types = [ (gt.attrsOf (tagOf f.checked)) ];
      ok.k = f.ok;
      bad.k = f.bad;
    };
  enforced =
    fs: door:
    lib.all (f: lib.all (p: served p.types p.ok && refused p.types p.bad) (positions door f)) fs;
in
{
  construct = [ "an-attrtag-tags-check-is-enforced" ];
  # the leaf form is read raw and through `defineType`: through `mkOptionType`, a leaf check held at a nixpkgs
  # container's element is served redeclared at the tag as at `listOf`'s element, a separate row
  check = asserts (
    lib.all (enforced forms) [
      (d: d)
      gt.defineType
    ]
    && enforced (lib.take 2 forms) genMerge.mkOptionType
  );
}
