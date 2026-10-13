# `redeclared-option-meets-where-a-join-renames-or-widens` — den-hoag-rmxbx (G11; with 6myw4, dm02y). One option
# redeclared where the base join RENAMES or WIDENS an operand is served by the meet (owner-ruled 2026-10-06),
# never refused where every declared check accepts the value. Each form, both orders:
#  - `enum`: `refined (enum [a b]) [≠b]` beside `refined (enum [b c]) [≠c]`. The base join is the union
#    `enum [a b c]`, and each refinement is owed relative to its own base (ADR-0039, enum extension stays a
#    union): "a" served, "b" and "c" each refused by the refinement whose own base holds it. Gen's engine and
#    nixpkgs' (the merge is gen-schema's relation, gen code under either).
#  - `portInt`: nixpkgs `port` beside `int`, which nixpkgs joins to bare `int`: 80 served, 70000 refused by
#    `port`'s check. Gen's engine only: nixpkgs' engine never reaches gen code for that pair, so its 70000
#    is nixpkgs' own drop (ADR-0039, Not covered).
#  - `attrs`: gen `attrs` beside nixpkgs `attrs`, which states no fold of its own: `{ a = 1; }` served by
#    gen's fold, "x" refused. Both engines.
# Red where any accepted value is refused (each form refused outright before G11) or any rejected value is
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
  ne = x: {
    check = v: v != x;
    message = "must not be ${x}";
  };
  ab = genSchema.refined (np.enum [
    "a"
    "b"
  ]) [ (ne "b") ];
  bc = genSchema.refined (np.enum [
    "b"
    "c"
  ]) [ (ne "c") ];
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
  forms = {
    enum = {
      tss = both [
        ab
        bc
      ];
      engines = [
        meetRead
        npRead
      ];
      v = {
        a = "a";
        b = "REFUSED";
        c = "REFUSED";
      };
      val = k: k;
    };
    portInt = {
      tss = both [
        np.port
        np.int
      ];
      engines = [ meetRead ];
      v = {
        "80" = 80;
        "70000" = "REFUSED";
      };
      val = lib.toInt;
    };
    attrs = {
      tss = both [
        genMerge.types.attrs
        np.attrs
      ];
      engines = [
        meetRead
        npRead
      ];
      v = {
        set = {
          a = 1;
        };
        str = "REFUSED";
      };
      val = k: if k == "set" then { a = 1; } else "x";
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
  construct = [ "redeclared-option-meets-where-a-join-renames-or-widens" ];
  check = asserts (builtins.all (n: holds forms.${n}) (builtins.attrNames forms));
}
