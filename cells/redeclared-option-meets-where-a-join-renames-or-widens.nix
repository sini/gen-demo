# `redeclared-option-meets-where-a-join-renames-or-widens` — den-hoag-rmxbx (G11; with 6myw4, dm02y), den-hoag-wsnn0. One option
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
#  - `refinedPortInt`: `refined port [≠1]` beside `refined int [≠3]`, whose base join renames `port` to `int`
#    (den-hoag-wsnn0): 4 served; 70000 (`port`), 1 and 3 (the refinements) refused. Both engines: the
#    merge is gen-schema's relation, gen code under either.
#  - `importedPortInt`: `port` and `int` each imported through `mkOptionType`, so the pair merges on the
#    stated relation's renaming join, met at the step: 8080 served, 70000 refused. Gen's engine.
#  - `authorFirst`: an author type (int, and even) imported through `mkOptionType`, whose stated relation
#    answers plain `int`, declared BEFORE `int`. Gen's engine asks the earlier relation and meets its
#    answer: 4 served (every declaration accepts it), 3 refused (the author rejects it). nixpkgs asks only
#    the later `int`, which refuses the pair, so its engine refuses both (`authorFirstNixpkgs`): gen serves
#    beyond nixpkgs here, bounded by the meet (ADR-0039).
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
  even =
    let
      self = lib.mkOptionType {
        name = "even";
        check = v: builtins.isInt v && lib.mod v 2 == 0;
        merge = lib.options.mergeEqualOption;
        functor = np.defaultFunctor "even" // {
          type = _: self;
          payload = { };
          binOp = _a: _b: { };
        };
        typeMerge = f: if f.name == "int" || f.name == "even" then np.int else null;
      };
    in
    self;
  notNum = n: {
    check = v: v != n;
    message = "must not be ${toString n}";
  };
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
    refinedPortInt = {
      tss = both [
        (genSchema.refined np.port [ (notNum 1) ])
        (genSchema.refined np.int [ (notNum 3) ])
      ];
      engines = [
        meetRead
        npRead
      ];
      v = {
        "4" = 4;
        "70000" = "REFUSED";
        "1" = "REFUSED";
        "3" = "REFUSED";
      };
      val = lib.toInt;
    };
    importedPortInt = {
      tss = both [
        (genMerge.mkOptionType np.port)
        (genMerge.mkOptionType np.int)
      ];
      engines = [ meetRead ];
      v = {
        "8080" = 8080;
        "70000" = "REFUSED";
      };
      val = lib.toInt;
    };
    authorFirst = {
      tss = [
        [
          (genMerge.mkOptionType even)
          np.int
        ]
      ];
      engines = [ meetRead ];
      v = {
        "4" = 4;
        "3" = "REFUSED";
      };
      val = lib.toInt;
    };
    authorFirstNixpkgs = {
      inherit (forms.authorFirst) tss val;
      engines = [ npRead ];
      v = {
        "4" = "REFUSED";
        "3" = "REFUSED";
      };
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
