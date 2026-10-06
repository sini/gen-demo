# `enum-redeclaration-unions` — C90, den-hoag-gen-types-read-surface-nqhoa. Two modules declare
# `weave` as a gen `enum "weave"` over different value sets. gen-merge reads both constructions back
# through gen-types' certifying `payloadOf` and merges them to the enum of their ordered union, which
# is nixpkgs' own `enum` functor `binOp`: `weave = "sateen"` reads `sateen`, and a value outside both
# sets is refused catchably. The same set declared twice reads `twill`, the control. It used to refuse
# the redeclaration, because nothing on a checker could be read back.
{
  asserts,
  genMerge,
}:
let
  read =
    sets: v:
    builtins.tryEval
      (genMerge.evalModuleTree { } (
        map (elems: {
          options.weave = genMerge.mkOption { type = genMerge.types.enum "weave" elems; };
        }) sets
        ++ [ { weave = v; } ]
      )).config.weave;
  twoSets = [
    [ "twill" ]
    [ "sateen" ]
  ];
in
{
  construct = [ "same-named-enum-redeclared-unioned" ];
  check = asserts (
    read twoSets "sateen" == {
      success = true;
      value = "sateen";
    }
    && !(read twoSets "satin").success
    &&
      read [
        [ "twill" ]
        [ "twill" ]
      ] "twill" == {
        success = true;
        value = "twill";
      }
  );
}
