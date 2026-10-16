# `foreign-check-beside-its-own-fold` — a-foreign-check-beside-a-records-own-fold-is-enforced, den-hoag-w68ud
# (ADR-0025 item 1). A gen record stating nixpkgs' `check` beside its own `mergeDefs`, and no check witness (a caller's
# record, raw or through `types.mkType`, alone or with an `admits` or a `verify` that admits every int), has the check
# applied to each definition before its fold, as nixpkgs' `mergeDefinitions` applies a descriptor's: a value only the
# check rejects is refused at the option, inside `listOf` and inside a submodule, and a value every predicate admits is
# served. In a union the check decides membership: `either <it> int` serves the rejected value by `int`, as nixpkgs'
# `either` over the same descriptor stated as `check` and `merge` does. The fold the check guards is the record's own,
# also where the record states a `merge` beside it; and a nesting container whose witness is gone and which states a
# check has it applied before its threaded fold, at the option and inside a submodule. gen-merge ran the record's own
# fold unchecked and served the rejected value silently.
# Each refusal stands beside its passing twin, so an engine refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.spool = genMerge.mkOption { inherit type; }; }
      { spool = v; }
    ]).config.spool;
  refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
  served = type: v: read type v == v;
  # the check rejects 3, alone or beside a domain that admits it
  record =
    r:
    {
      name = "selvage";
      check = v: builtins.isInt v && v != 3;
      mergeDefs = loc: defs: lib.mergeEqualOption loc defs;
    }
    // r;
  rows = [
    { }
    { admits = builtins.isInt; }
    { verify = v: if builtins.isInt v then null else "not an int"; }
    { merge = loc: defs: "another fold"; }
  ];
  positions = [
    {
      ty = x: x;
      v = x: x;
    }
    {
      ty = gt.listOf;
      v = x: [ x ];
    }
    {
      ty = x: gt.submodule { options.a = genMerge.mkOption { type = x; }; };
      v = x: { a = x; };
    }
  ];
  holds =
    r:
    builtins.all
      (
        x:
        builtins.all (p: refused (p.ty x) (p.v 3) && served (p.ty x) (p.v 4)) positions
        && read (gt.either x gt.int) 3 == 3
      )
      [
        (record r)
        (gt.mkType (record r))
      ];
  # the check rejects a `warp` key; the container nests a submodule, so it folds threaded
  nest =
    builtins.removeAttrs
      (gt.attrsOf (gt.submodule { options.a = genMerge.mkOption { type = gt.int; }; }))
      [
        "_checkWitness"
      ]
    // {
      check = v: builtins.isAttrs v && !(v ? warp);
    };
  threaded =
    refused nest { warp.a = 1; }
    && served nest { weft.a = 1; }
    && refused (gt.submodule { options.b = genMerge.mkOption { type = nest; }; }) { b.warp.a = 1; }
    && served (gt.submodule { options.b = genMerge.mkOption { type = nest; }; }) { b.weft.a = 1; };
  twin = lib.types.mkOptionType {
    name = "selvage";
    check = v: builtins.isInt v && v != 3;
    merge = loc: defs: lib.mergeEqualOption loc defs;
  };
  nixpkgs =
    let
      readN =
        type: v:
        (lib.evalModules {
          modules = [
            { options.spool = lib.mkOption { inherit type; }; }
            { spool = v; }
          ];
        }).config.spool;
    in
    !(builtins.tryEval (builtins.deepSeq (readN twin 3) null)).success
    && readN twin 4 == 4
    && readN (lib.types.either twin lib.types.int) 3 == 3;
in
{
  construct = [ "a-foreign-check-beside-a-records-own-fold-is-enforced" ];
  check = asserts (builtins.all holds rows && threaded && nixpkgs);
}
