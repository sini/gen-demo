# `a-restated-fold-folds-by-its-records-completion` — nesting-type-empty-value-is-its-module-set-over-no-definitions,
# den-hoag-d2myd (ADR-0039 serve half). A `//` copy that restates a record's fold and leaves its `merge` as it was states
# two folds that disagree; nixpkgs' `evalModules` runs the `merge`. gen-merge's engine folds such a declared record by
# the fold of the record it was completed with: a copy of gen's `submodule` over no definitions is its module set's value
# and refuses a nested option's rejected value, and a copy of `listOf int` with its fold replaced concatenates and
# refuses a rejected element, at the option and as a container's element, raw and (the container) through
# `types.defineType`, as nixpkgs serves and refuses the same record. gen-merge used to run the restated fold and serve
# `{ }`, the last definition, or the rejected value. The intact records are the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  lastSpool = loc: defs: (lib.last defs).value;
  read =
    engine: type: vs:
    let
      mods = [
        { options.spool = (if engine == "gen" then genMerge else lib).mkOption { inherit type; }; }
      ]
      ++ map (v: { spool = v; }) vs;
    in
    if engine == "gen" then
      (genMerge.evalModuleTree { } mods).config.spool
    else
      (lib.evalModules { modules = mods; }).config.spool;
  attempt =
    engine: type: vs:
    builtins.tryEval (builtins.deepSeq (read engine type vs) (read engine type vs));
  agree = type: vs: attempt "gen" type vs == attempt "np" type vs;
  refused = type: vs: !(attempt "gen" type vs).success;
  loom = gt.submodule {
    options.warp = genMerge.mkOption {
      type = gt.int;
      default = 0;
    };
  };
  skein = gt.listOf gt.int;
  restated =
    t:
    t
    // {
      mergeDefs = t.mergeDefs // {
        threaded = _: lastSpool;
      };
    };
  replaced =
    t:
    t
    // {
      mergeDefs = {
        __functor = _: lastSpool;
        threaded = _: lastSpool;
      };
    };
  positions = [
    {
      w = t: t;
      v = x: x;
    }
    {
      w = gt.listOf;
      v = x: [ x ];
    }
    {
      w = gt.attrsOf;
      v = x: { bobbin = x; };
    }
  ];
  nesting =
    t:
    lib.all (
      p:
      agree (p.w t) [ (p.v { }) ]
      && (attempt "gen" (p.w t) [ (p.v { }) ]).value == p.v { warp = 0; }
      && refused (p.w t) [ (p.v { warp = "x"; }) ]
      && agree (p.w t) [ (p.v { warp = 2; }) ]
    ) positions;
  # the reference is nixpkgs over the record as `//` left it: the door re-derives `merge` from the restated fold
  container =
    t: ref:
    lib.all (
      p:
      attempt "gen" (p.w t) [
        (p.v [ 1 ])
        (p.v [ 2 ])
      ] == attempt "np" (p.w ref) [
        (p.v [ 1 ])
        (p.v [ 2 ])
      ]
      && refused (p.w t) [ (p.v [ "x" ]) ]
    ) positions;
in
{
  construct = [ "nesting-type-empty-value-is-its-module-set-over-no-definitions" ];
  check = asserts (
    lib.all nesting [
      loom
      (restated loom)
      (replaced loom)
    ]
    && container skein skein
    && container (replaced skein) (replaced skein)
    && container (gt.defineType (replaced skein)) (replaced skein)
  );
}
