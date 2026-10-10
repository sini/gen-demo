# `self-referential-checked-container-crosses-both-doors` — den-hoag-zwqq2. A gen-types checked list whose
# element is itself, re-completed through gen-merge's two doors that take a caller's record, `mkOptionType`
# and `types.defineType`, has a value and is a usable type: it admits `[ [ ] [ [ ] ] ]` and refuses `[ 1 ]`.
# The doors decided whether to return the record as it is by comparing its name, which renders its element,
# which is the door's own result: an uncatchable infinite recursion on every evaluator. And a raw gen-types
# `verify` copy declared beside gen-merge's `enum` is refused, catchably: the import door returned it as it
# is, publishing gen-types' two-argument `check`, and the declaration aborted. The `enum` twins beside each
# other serve `"b"`, so a fold refusing every declaration list cannot pass.
{
  asserts,
  genMerge,
  inputs,
}:
let
  gt = inputs.gen.lib.modules.types;
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types
      ++ [
        { spool = v; }
      ]
    )).config.spool;
  served = types: v: builtins.tryEval (builtins.deepSeq (read types v) (read types v));
  admits =
    door:
    let
      s = door (gt.checkedListOf s);
    in
    (builtins.tryEval (builtins.seq s null)).success
    && s.check [
      [ ]
      [ [ ] ]
    ]
    && !(s.check [ 1 ]);
  twin = genMerge.types.enum "e" [
    "a"
    "b"
  ];
  rawCopy =
    gt.enum "e" [
      "a"
      "b"
    ]
    // {
      verify = v: if v == "a" then "no" else null;
    };
in
{
  construct = [ "self-referential-checked-container-crosses-both-doors" ];
  check = asserts (
    admits genMerge.mkOptionType
    && admits genMerge.types.defineType
    &&
      served [ twin twin ] "b" == {
        success = true;
        value = "b";
      }
    && !(served [ (genMerge.mkOptionType rawCopy) twin ] "b").success
  );
}
