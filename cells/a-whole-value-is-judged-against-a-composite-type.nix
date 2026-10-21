# `a-whole-value-is-judged-against-a-composite-type` — den-hoag-2wo5a. gen-merge's `verifyValue` judges a whole
# value against a composite option type in one call, `null` where gen's fold serves it and otherwise a string
# naming the failing position: `attrsOf (listOf (submodule { gusset : int }))` takes a `thimble` whose entries
# all state an int `gusset`, and refuses one whose second entry states a string there, naming `thimble`, the
# second entry and `gusset`. The fold agrees: it serves the first and refuses the second.
#
# Red before gen-merge published `verifyValue`: the attribute is missing, so the cell aborts.
{ asserts, genMerge }:
let
  T = genMerge.types;
  bolt = T.attrsOf (
    T.listOf (
      T.submodule {
        options.gusset = genMerge.mkOption { type = T.int; };
      }
    )
  );
  good.thimble = [ { gusset = 1; } ];
  bad.thimble = [
    { gusset = 1; }
    { gusset = "x"; }
  ];
  folds =
    v:
    (builtins.tryEval (
      builtins.deepSeq
        (genMerge.evalModuleTree { } [
          { options.bolt = genMerge.mkOption { type = bolt; }; }
          { bolt = v; }
        ]).config.bolt
        true
    )).success;
in
{
  construct = [ "a-whole-value-is-judged-against-a-composite-type" ];
  check = asserts (
    genMerge.verifyValue bolt good == null
    &&
      genMerge.verifyValue bolt bad
      == "`thimble.\"[definition 1-entry 2]\".gusset': expected type 'int' but value \"x\" is of type 'string'"
    && folds good
    && !(folds bad)
  );
}
