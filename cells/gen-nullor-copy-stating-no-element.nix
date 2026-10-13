# `gen-nullor-copy-stating-no-element` — den-hoag-i3kma. A `//` copy of gen's `nullOr` over a gen submodule whose
# `carries` states no element (or names an unknown role), and gen's `nullOr` renamed, under gen's `attrsOf`, nixpkgs'
# `attrsOf` and gen's `lazyAttrsOf`. gen's engine serves the value nixpkgs' engine serves its all-nixpkgs twin. The
# walk keys such a copy where it is read, a container node, while the fold's mark excluded every record named
# `nullOr`, so the fold never read the node it minted: an uncatchable `attribute 'config' missing` (ADR-0025 item 1,
# ADR-0039).
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  nt = lib.types;
  subOpts = mkOption: int: {
    key = "gen-nullor-copy-sub";
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
  shapes = [
    (s: k: k.attrsOf (k.nullOr s // { carries.alternatives = [ s ]; }))
    (s: k: nt.attrsOf (k.nullOr s // { carries.thimble = s; }))
    (s: k: k.lazyAttrsOf (k.nullOr s // { name = "thimbleOr"; }))
  ];
in
{
  construct = [ "a-gen-nullor-copy-stating-no-element-serves-nixpkgs-value" ];
  check = asserts (lib.all served shapes);
}
