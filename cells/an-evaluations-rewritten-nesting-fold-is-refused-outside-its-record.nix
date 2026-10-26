# `an-evaluations-rewritten-nesting-fold-is-refused-outside-its-record` — a-records-admits-is-refused-outside-at-every-door,
# den-hoag-qmk09 (ADR-0025 item 1). An evaluation's own type (`(evalModuleTree …).type`, which nixpkgs'
# `(evalModules …).type` is) whose threaded fold a `//` copy rewrites keeps the record's `check` and witness, and its
# strict fold is no longer the one the record was completed with. gen-merge's engine refuses a definition outside the
# record's domain as the element of a `listOf` and an `attrsOf`, raw and through `types.defineType`, as nixpkgs'
# `evalModules` refuses the same copy, and serves an in-domain definition. At the option the copy keeps its reporting
# fold, so an empty definition still serves the declared default, as nixpkgs serves it. gen-merge used to fold the copy's
# element by the rewritten fold and serve the outside value silently. Each refusal stands beside its passing twin, and
# the evaluation's own type is the control.
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
  loom =
    (genMerge.evalModuleTree { } [
      {
        options.warp = genMerge.mkOption {
          type = gt.int;
          default = 0;
        };
      }
    ]).type;
  copy = loom // {
    mergeDefs = loom.mergeDefs // {
      threaded = _: lastSpool;
    };
  };
  doors = [
    (t: t)
    gt.defineType
  ];
  # the copy as a container's element, with the value placed there
  positions = [
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
    ) positions
    && refused "gen" t "spool"
    && served "gen" t { } { warp = 0; }
    && served "np" t { } { warp = 0; }
    && served "gen" t { warp = 2; } { warp = 2; };
in
{
  construct = [ "a-records-admits-is-refused-outside-at-every-door" ];
  check = asserts (lib.all (door: holds (door copy) && holds (door loom)) doors);
}
