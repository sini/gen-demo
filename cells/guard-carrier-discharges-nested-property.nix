# `guard-carrier-discharges-nested-property` — den-hoag-15wnx (ADR-0025 item 1). A plain definition
# beside a guard record holds property markers at nested aspect keys. The carrier's survivors fold by
# the module system's law, and gen-merge's `anything` now discharges a marker below the top level as
# nixpkgs' does. Before, the markers were carried into the fired value as data at rc 0: an `mkIf
# false`'s content was served, and one survivor skipped the law altogether. A field whose every
# definition discharges is refused by name where it is read, as the aspect type refuses it. Control: a
# plain nested value.
{
  asserts,
  genAspects,
  genMerge,
}:
let
  gv = genAspects.mkGuardVocab { };
  always = gv.vocab.always;
  never = gv.vocab.whenEq [ "thimble" "name" ] "blade";
  fire =
    defs:
    gv.applyGuard { thimble.name = "cortex"; }
      (genMerge.evalModuleTree { } (
        [
          { options.aspects = (genAspects.mkAspectSchema { }).mkAspectOption { }; }
        ]
        ++ map (d: { aspects.dup = d; }) defs
      )).config.aspects.dup;
  ok = v: (builtins.tryEval (builtins.deepSeq v true)).success;
  plain = {
    hem = genMerge.mkIf false { description = "hem"; };
    tuck = genMerge.mkIf true { description = "tuck"; };
    cuff = genMerge.mkMerge [
      { description = "cuff"; }
      { seam.description = "seam"; }
    ];
    pocket.description = "pocket";
  };
  fired = fire [
    (always { description = "coat"; })
    plain
  ];
  quiet = fire [
    (never { description = "coat"; })
    plain
  ];
in
{
  construct = [ "a-guard-carrier-discharges-a-property-nested-in-its-plain-definition" ];
  check = asserts (
    !(ok fired.hem)
    && (fired.tuck.description or null) == "tuck"
    && (fired.cuff.description or null) == "cuff"
    && (fired.cuff.seam.description or null) == "seam"
    && (quiet.tuck.description or null) == "tuck"
    && fired.pocket.description == "pocket"
    && quiet.pocket.description == "pocket"
  );
}
