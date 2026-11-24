# `guard-carrier-merges-by-module-law` — C172, den-hoag-ywlww (ADR-0025 item 1). A parametric aspect
# defined more than once is a guard carrier, and its surviving fragments are merged by T4's law at its
# top-level fields (the same definitions with each guard replaced by its body): a declared `includes` concatenates, as its
# `listOf` does, attrsets merge per key, and a conflicting scalar is refused by name, as nixpkgs'
# `anything` refuses it (nixpkgs' `anything` also refuses two unequal lists, so the list law is T4's,
# not `anything`'s). Before, the discharge folded with `//`, so two firing
# definitions with different `description` read one value, and `includes = [ "p" ]` beside
# `includes = [ "q" ]` read `[ "p" ]`, both at rc 0. Controls: equal scalars agree, a definition
# whose guard does not fire does not conflict, a single definition is unchanged.
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
  ok = v: (builtins.tryEval (builtins.deepSeq v true)).success;
in
{
  construct = [ "guard-carrier-merges-by-the-module-law" ];
  check = asserts (
    !(ok (fire [
      (always { description = "a"; })
      (always { description = "b"; })
    ]))
    && !(ok (fire [
      { description = "u"; }
      (always { description = "g"; })
    ]))
    &&
      builtins.sort (x: y: x < y) (
        (fire [
          (always { includes = [ "p" ]; })
          (always { includes = [ "q" ]; })
        ]).includes
      ) == [
        "p"
        "q"
      ]
    &&
      (fire [
        (always { description = "s"; })
        (always { description = "s"; })
      ]).description == "s"
    &&
      (fire [
        (always { description = "a"; })
        (gv.vocab.whenEq [ "thimble" "name" ] "blade" { description = "b"; })
      ]).description == "a"
    && (fire [ (always { description = "solo"; }) ]).description == "solo"
  );
}
