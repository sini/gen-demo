# `guard-carrier-priority-over-a-typed-position` — den-hoag-fjdnf (ADR-0029, ADR-0039 serve half). A plain
# definition beside a guard record puts a priority over a nested value holding an `includes` list, a typed
# position. The typed half is folded when the carrier is built and keeps the priority that selected it, so
# the priority ranges over the fired record's content as the module system ranges it: `mkForce` beats the
# record at `sleeve`, `mkDefault` loses to it at `collar`. Before, gen-aspects refused both by name (a
# stated shortfall). Control: a plain nested `includes` beside the record's own nested content.
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
      sleeve.description = "sleeve";
      collar.description = "stiff";
      pocket.description = "pocket";
    })
    {
      sleeve = genMerge.mkForce { includes = [ { description = "lining"; } ]; };
      collar = genMerge.mkDefault {
        includes = [ { description = "stud"; } ];
        description = "soft";
      };
      pocket.includes = [ { description = "flap"; } ];
    }
  ];
in
{
  construct = [
    "a-priority-over-a-guard-carriers-typed-nested-position-ranges-as-the-module-systems"
  ];
  check = asserts (
    descs fired.sleeve == [ "lining" ]
    && !(fired.sleeve ? description)
    && fired.collar.description == "stiff"
    && descs fired.collar == [ ]
    && descs fired.pocket == [ "flap" ]
    && fired.pocket.description == "pocket"
    && fired.description == "coat"
  );
}
