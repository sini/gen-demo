# `renamed-foreign-nullor-union-member` — den-hoag-i3kma. A nixpkgs `nullOr` over a gen submodule, its functor renamed
# so gen's re-homing does not recognise it, is a member of a nixpkgs `either` under `attrsOf`, and of gen's own
# `lazyAttrsOf`. gen's engine serves the value nixpkgs' engine serves its all-nixpkgs twin, as it does for the
# un-renamed member. The record keeps nixpkgs' name `nullOr` and carries no element, and gen's walk read the element
# off any record of that name: an uncatchable `attribute 'carries' missing` (ADR-0025 item 1, ADR-0039).
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  nt = lib.types;
  subOpts = mkOption: int: {
    key = "renamed-foreign-nullor-sub";
    options.a = mkOption {
      type = int;
      default = 0;
    };
    options.b = mkOption {
      type = int;
      default = 0;
    };
  };
  sub = t.submodule (subOpts genMerge.mkOption t.int);
  ntSub = nt.submodule (subOpts lib.mkOption nt.int);
  renamed =
    ty:
    ty
    // {
      functor = ty.functor // {
        name = "thimble";
      };
    };
  v = {
    gusset = {
      a = 1;
    };
  };
  gen =
    ty:
    (genMerge.evalModuleTree { } [
      { options.bobbin = genMerge.mkOption { type = ty; }; }
      { bobbin = v; }
    ]).config.bobbin;
  twin =
    ty:
    (lib.evalModules {
      modules = [
        { options.bobbin = lib.mkOption { type = ty; }; }
        { bobbin = v; }
      ];
    }).config.bobbin;
  served =
    mk:
    let
      g = builtins.tryEval (builtins.deepSeq (gen (mk sub t)) (gen (mk sub t)));
      n = twin (mk ntSub nt);
    in
    g.success && g.value == n && n.gusset.a == 1;
  shapes =
    map
      (rn: [
        (s: _: nt.attrsOf (nt.either (rn (nt.nullOr s)) nt.str))
        (s: k: k.lazyAttrsOf (nt.either (rn (nt.nullOr s)) nt.str))
      ])
      [
        (ty: ty)
        renamed
      ];
in
{
  construct = [ "a-renamed-nixpkgs-nullor-union-member-serves-nixpkgs-value" ];
  check = asserts (lib.all served (lib.concatLists shapes));
}
