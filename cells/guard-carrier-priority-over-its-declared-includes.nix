# `guard-carrier-priority-over-its-declared-includes` — den-hoag-5ov3p (ADR-0029). A plain definition beside a
# guard record puts a priority on the carrier's DECLARED `includes` list, at the top and one key down. The typed
# child folds that option when the carrier is built and keeps the priority that selected its winners, so the
# priority ranges over the fired record's `includes` as the module system ranges it: `mkForce` beats the record's
# list at the top, `mkDefault` loses to it at `sleeve`. Before, the priority was spent at load and both lists
# were served concatenated. Control: a plain `includes` at `collar`, where the record writes only a description.
{
  asserts,
  genAspects,
  genMerge,
}:
let
  gv = genAspects.mkGuardVocab { };
  always = gv.vocab.always;
  fire =
    defs:
    gv.applyGuard { thimble.name = "cortex"; }
      (genMerge.evalModuleTree { } (
        [
          { options.aspects = (genAspects.mkAspectSchema { }).mkAspectOption { }; }
        ]
        ++ map (d: { aspects.dup = d; }) defs
      )).config.aspects.dup;
  descs = v: map (e: e.description) (v.includes or [ ]);
  fired = fire [
    (always {
      description = "coat";
      includes = [ { description = "cuff"; } ];
      sleeve.includes = [ { description = "seam"; } ];
      collar.description = "stiff";
    })
    {
      includes = genMerge.mkForce [ { description = "button"; } ];
      sleeve.includes = genMerge.mkDefault [ { description = "hem"; } ];
      collar.includes = [ { description = "stud"; } ];
    }
  ];
in
{
  construct = [
    "a-priority-on-a-guard-carriers-declared-includes-ranges-as-the-module-systems"
  ];
  check = asserts (
    descs fired == [ "button" ]
    && descs fired.sleeve == [ "seam" ]
    && descs fired.collar == [ "stud" ]
    && fired.collar.description == "stiff"
    && fired.description == "coat"
  );
}
