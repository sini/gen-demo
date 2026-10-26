# `a-rewritten-nesting-fold-is-refused-outside-its-record` — a-records-admits-is-refused-outside-at-every-door,
# den-hoag-qmk09 (ADR-0025 item 1). A `//` copy of gen's `submodule` that rewrites its threaded fold, or replaces its
# fold whole, keeps the record's `check` and witness, and its fold is no longer the one the record was completed with.
# gen-merge's engine refuses a definition outside the record's domain, raw and through `types.defineType`, at the
# option and as the element of a `listOf` and an `attrsOf` (whose direct nesting fold is taken only for an element whose
# fold is its own), as nixpkgs' `evalModules` refuses the same copy, and serves an in-domain definition. gen-merge used to read the copy's fold as
# the record's own and serve the outside value silently. Each refusal stands beside its passing twin, and the intact
# submodule is the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  lastSpool = loc: defs: (lib.last defs).value;
  read =
    engine: type: v:
    let
      mods = [
        { options.spool = (if engine == "gen" then genMerge else lib).mkOption { inherit type; }; }
        { spool = v; }
      ];
    in
    if engine == "gen" then
      (genMerge.evalModuleTree { } mods).config.spool
    else
      (lib.evalModules { modules = mods; }).config.spool;
  attempt =
    engine: type: v:
    builtins.tryEval (builtins.deepSeq (read engine type v) (read engine type v));
  refused =
    engine: type: v:
    !(attempt engine type v).success;
  served =
    engine: type: v: want:
    attempt engine type v == {
      success = true;
      value = want;
    };
  loom = gt.submodule {
    options.warp = genMerge.mkOption {
      type = gt.int;
      default = 0;
    };
  };
  copies = [
    (
      loom
      // {
        mergeDefs = loom.mergeDefs // {
          threaded = _: lastSpool;
        };
      }
    )
    (
      loom
      // {
        mergeDefs = {
          __functor = _: lastSpool;
          threaded = _: lastSpool;
        };
      }
    )
  ];
  doors = [
    (t: t)
    gt.defineType
  ];
  # where the copy sits: at the option, and as a container's element, with the value placed there
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
  holds =
    t:
    lib.all (
      p:
      refused "gen" (p.w t) (p.v "spool")
      && served "gen" (p.w t) (p.v { warp = 2; }) (p.v { warp = 2; })
      && refused "np" (p.w t) (p.v "spool")
    ) positions;
in
{
  construct = [ "a-records-admits-is-refused-outside-at-every-door" ];
  check = asserts (
    lib.all (door: lib.all (c: holds (door c)) copies) doors
    && holds loom
    && refused "gen" (gt.defineType loom) "spool"
  );
}
