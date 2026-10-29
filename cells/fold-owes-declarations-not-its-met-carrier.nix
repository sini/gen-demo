# `fold-owes-declarations-not-its-met-carrier` — den-hoag-meet-carrier-join-check-reowed-15va3. An option declared
# `[ int int nTM ]`, where `nTM`'s author `typeMerge` narrows `int` to `ints.positive`: the narrowing is a relation's
# answer, not a declaration's check, and nixpkgs' next step drops it. Every declared check admits `-1`, and both
# engines serve it. gen-merge owed the record its step built (the narrowed join) again at the next step, as if it were
# declared, and refused. The control: `listOf ints.positive` declared beside two `listOf int` (gen's own container,
# three declarations) still refuses `[ -1 ]`, because a declared check met at a role is owed by the step that met it;
# nixpkgs drops it there.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  g = genMerge.types;
  nTM = t.mkOptionType {
    name = "nTM";
    check = builtins.isInt;
    functor = t.defaultFunctor "int";
    typeMerge = f: if f.name == "int" then t.ints.positive else null;
  };
  served =
    eval: mkOption: types: v:
    let
      r = builtins.tryEval (
        let
          x =
            (eval (map (type: { options.y = mkOption { inherit type; }; }) types ++ [ { y = v; } ])).config.y;
        in
        builtins.deepSeq x x
      );
    in
    if r.success then { value = r.value; } else null;
  gen = served (modules: genMerge.evalModuleTree { } modules) genMerge.mkOption;
  ref = served (modules: lib.evalModules { inherit modules; }) lib.mkOption;
  inList = [
    (g.listOf g.int)
    (g.listOf g.int)
    (g.listOf t.ints.positive)
  ];
in
{
  construct = [ "a-narrowing-relation-answer-is-not-owed-as-a-declared-check" ];
  check = asserts (
    gen [ g.int g.int nTM ] (-1) == {
      value = -1;
    }
    && ref [ t.int t.int nTM ] (-1) == { value = -1; }
    && gen inList [ (-1) ] == null
    && gen inList [ 2 ] == { value = [ 2 ]; }
  );
}
