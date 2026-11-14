# `a-checked-door-return-beside-gen-lists-under-nixpkgs-evaluation` — den-hoag-redeclaration-beside-foreign-slope-vhcac. One
# option is declared N = 2, 4 and 8 times under nixpkgs' `evalModules`: first a door return (`genMerge.mkOptionType`) over
# nixpkgs' `addCheck (listOf (enum [ "a" ]))` admitting lists shorter than two, then N − 1 gen `listOf (enum [ "b" ])`.
# nixpkgs folds the declarations by asking each accumulated type's `typeMerge`, so from the third declaration on it asks a
# met record, whose later join gen-merge asks of the root join and meets with the met record. `[ "a" ]` is served at every N,
# as one declaration alone serves it. This cell is EXERCISE for that fold's cost, which the den-hoag-vhcac c3 build reads by
# thunk counts; what the fold owes a value the wrapper's check rejects is not asserted here.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  short = v: builtins.isList v && builtins.length v < 2;
  door = genMerge.mkOptionType (t.addCheck (t.listOf (t.enum [ "a" ])) short);
  served =
    n:
    let
      r = builtins.tryEval (
        let
          c =
            (lib.evalModules {
              modules = [
                { options.loom = lib.mkOption { type = door; }; }
              ]
              ++ builtins.genList (_: {
                options.loom = lib.mkOption { type = genMerge.types.listOf (t.enum [ "b" ]); };
              }) (n - 1)
              ++ [ { loom = [ "a" ]; } ];
            }).config;
        in
        builtins.deepSeq c.loom c.loom
      );
    in
    if r.success then { value = r.value; } else null;
in
{
  construct = [ "redeclared-option-accepts-only-what-every-declaration-accepts" ];
  check = asserts (
    map served [
      2
      4
      8
    ] == builtins.genList (_: { value = [ "a" ]; }) 3
  );
}
