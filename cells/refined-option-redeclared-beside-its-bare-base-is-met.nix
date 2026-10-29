# `refined-option-redeclared-beside-its-bare-base-is-met` — den-hoag-pbble. One option declared once as a `refined` type
# and once as that type's own BARE base is the meet, `{v:B | e} ⊓ B = {v:B | e}` (ADR-0039, the meet): a value every
# declaration accepts is served, a value the refinement rejects and a value the base rejects are refused. Each form, both
# orders:
#  - `gtEnum`: `refined (gen enum [a b]) [≠a]` beside the gen `enum [a b]`: "b" served, "a" and "c" refused. Gen's engine
#    and nixpkgs' (gen code decides in both: the refined relation, or the bare gen base deferring to it).
#  - `gtInt`: `refined int [≠3]` beside `int`: 4 served, 3 and "x" refused. Both engines.
#  - `gSub`: `refined (gen submodule) [a ≠ 2]` beside the same submodule: `{ a = 1; }` served, `{ a = 2; }` refused. Both
#    engines.
#  - `widen`: `refined (gen enum [a b]) [≠a]` beside the gen `enum [b c]`: the union `[a b c]` with the refinement owed
#    relative to its own base, so "b" and "c" served, "a" and "d" refused. Both engines.
#  - `npEnum`: `refined (nixpkgs enum [a b]) [≠a]` beside the nixpkgs `enum [a b]`, in gen's engine, both orders, and in
#    nixpkgs' engine with the bare base declared first (the refined relation decides). With the refined type first,
#    nixpkgs' engine asks the nixpkgs enum's own `typeMerge`, which refuses on the name: that order is nixpkgs' code
#    (den-hoag-phi48), not this cell's.
# Red where any accepted value is refused (each form refused outright before den-hoag-pbble) or any rejected value is
# served.
{
  asserts,
  genMerge,
  genSchema,
  lib,
  meetRead,
}:
let
  np = lib.types;
  gt = genMerge.types;
  ne = x: {
    check = v: v != x;
    message = "must not be ${toString x}";
  };
  npRead =
    ts: v:
    let
      r = lib.evalModules {
        modules = map (t: { options.x = lib.mkOption { type = t; }; }) ts ++ [ { x = v; } ];
      };
      tried = builtins.tryEval (builtins.deepSeq r.config.x r.config.x);
    in
    if tried.success then tried.value else "REFUSED";
  both = ts: [
    ts
    (lib.reverseList ts)
  ];
  ab = [
    "a"
    "b"
  ];
  # no `default`: the two declarations' module sets merge, and two copies of one option both stating `default` are refused (nixpkgs' `bothHave`)
  gSub = gt.submodule { options.a = genMerge.mkOption { type = gt.int; }; };
  forms = {
    gtEnum = {
      tss = both [
        (genSchema.refined (gt.enum "e" ab) [ (ne "a") ])
        (gt.enum "e" ab)
      ];
      engines = [
        meetRead
        npRead
      ];
      v = {
        b = "b";
        a = "REFUSED";
        c = "REFUSED";
      };
      val = k: k;
    };
    gtInt = {
      tss = both [
        (genSchema.refined gt.int [ (ne 3) ])
        gt.int
      ];
      engines = [
        meetRead
        npRead
      ];
      v = {
        "4" = 4;
        "3" = "REFUSED";
        x = "REFUSED";
      };
      val = k: if k == "x" then "x" else lib.toInt k;
    };
    gSub = {
      tss = both [
        (genSchema.refined gSub [
          {
            check = v: (v.a or 0) != 2;
            message = "a must not be 2";
          }
        ])
        gSub
      ];
      engines = [
        meetRead
        npRead
      ];
      v = {
        one = {
          a = 1;
        };
        two = "REFUSED";
      };
      val = k: { a = if k == "one" then 1 else 2; };
    };
    widen = {
      tss = both [
        (genSchema.refined (gt.enum "e" ab) [ (ne "a") ])
        (gt.enum "e" [
          "b"
          "c"
        ])
      ];
      engines = [
        meetRead
        npRead
      ];
      v = {
        b = "b";
        c = "c";
        a = "REFUSED";
        d = "REFUSED";
      };
      val = k: k;
    };
    npEnum = {
      tss = both [
        (genSchema.refined (np.enum ab) [ (ne "a") ])
        (np.enum ab)
      ];
      engines = [ meetRead ];
      v = {
        b = "b";
        a = "REFUSED";
        c = "REFUSED";
      };
      val = k: k;
    };
    npEnumBareFirst = {
      tss = [
        [
          (np.enum ab)
          (genSchema.refined (np.enum ab) [ (ne "a") ])
        ]
      ];
      engines = [ npRead ];
      inherit (forms.npEnum) v val;
    };
  };
  holds =
    f:
    builtins.all (
      read:
      builtins.all (ts: builtins.all (k: read ts (f.val k) == f.v.${k}) (builtins.attrNames f.v)) f.tss
    ) f.engines;
in
{
  construct = [ "refined-option-redeclared-beside-its-bare-base-is-met" ];
  # per form, for the probe; the corpus reads `check`
  perForm = builtins.mapAttrs (_: holds) forms;
  check = asserts (builtins.all (n: holds forms.${n}) (builtins.attrNames forms));
}
