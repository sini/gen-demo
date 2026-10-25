# `held-check-through-mk-option-type` — a-check-held-in-a-container-through-mk-option-type-is-enforced, den-hoag-8uwxu
# (ADR-0025 item 1, ADR-0039). A check held below a nixpkgs container survives gen-merge's published `mkOptionType`.
# An `addCheck`'d leaf at an `attrTag` tag, a `listOf` element or an `attrsOf` element, declared twice or beside the
# unchecked container in either order, is met at the role the container holds it in. A gen `int`'s `verify` copy below
# a nixpkgs `attrsOf`, `lazyAttrsOf`, `listOf`, `nullOr` or `either`, declared alone, is read where gen's fold reads
# it, and through `deriveType` the same container serves the value the copy admits. A value the check admits reads as
# nixpkgs reads it, and a value it rejects is refused by name. gen-merge served the rejected value silently, and
# refused the admitted value through `deriveType`.
# Each refusal stands beside its passing twin, so a door refusing everything cannot pass, and neither can one serving
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
  door = genMerge.mkOptionType;
  leaf = ft.addCheck ft.int (v: v != 5);
  holders = [
    {
      mk = t: ft.attrTag { weft = lib.mkOption { type = t; }; };
      w = v: { weft = v; };
    }
    {
      mk = ft.listOf;
      w = v: [ v ];
    }
    {
      mk = ft.attrsOf;
      w = v: { k = v; };
    }
  ];
  met =
    h:
    lib.all (types: served types (h.w 2) && refused types (h.w 5)) [
      [ (door (h.mk leaf)) ]
      [
        (door (h.mk leaf))
        (door (h.mk leaf))
      ]
      [
        (h.mk ft.int)
        (door (h.mk leaf))
      ]
      [
        (door (h.mk leaf))
        (h.mk ft.int)
      ]
    ];
  copy = gt.int // {
    verify = v: if v < 10 then null else "the bobbin holds at most nine";
  };
  containers = [
    {
      mk = ft.attrsOf;
      w = v: { k = v; };
    }
    {
      mk = ft.lazyAttrsOf;
      w = v: { k = v; };
    }
    {
      mk = ft.listOf;
      w = v: [ v ];
    }
    {
      mk = ft.nullOr;
      w = v: v;
    }
    {
      mk = t: ft.either t ft.str;
      w = v: v;
    }
  ];
  copied =
    c:
    served [ (door (c.mk copy)) ] (c.w 1)
    && refused [ (door (c.mk copy)) ] (c.w 20)
    && served [ (genMerge.deriveType { } "bobbin" (c.mk copy)) ] (c.w 1);
in
{
  construct = [ "a-check-held-in-a-container-through-mk-option-type-is-enforced" ];
  check = asserts (lib.all met holders && lib.all copied containers);
}
