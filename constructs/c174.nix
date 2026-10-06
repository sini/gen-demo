# ── C174 — an instance carries its instantiation scope (gen-aspects; den-hoag-ohvjc). Two closure
# aspects lowered by gen-rules' `defunctionalize`: `selvage { thimble }` includes a closure reading
# `bobbin`, and `warp { thimble }` includes one reading only `thimble`, which includes one reading
# `bobbin`. Each is minted through `instancesFor` at a thimble-only scope, so the `bobbin` closure is
# left in the vertex's entry as a deferred door node (at depth 2, below the middle closure, which fired
# in place). Fired later per bobbin through `instanceOf` handed the vertex's `scope`, it reads its
# closure there; handed none, the door re-applies the outer. The firing door here is the same door with
# every registered closure replaced by a throw, so reading the scope and re-applying are told apart
# without a trace.
{
  genRules,
  genAspects,
  genMerge,
  inputs,
}:
let
  D = [
    "thimble"
    "bobbin"
  ];
  cnf = {
    entityKinds = D;
    keySemantics.nixos.category = "class";
    aspectModules = [ (genRules.lambdasMount "lambdas") ];
  };
  load = genRules.defunctionalize {
    inherit cnf;
    declared = D;
    key = "gen-demo:c174";
    lambdasPath = [ "lambdas" ];
    aspectPaths = [ [ "aspects" ] ];
    rulePaths = [ ];
  };
  tree = genMerge.evalModuleTree { } [
    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
    { options.lambdas = genRules.lambdas; }
    (load {
      aspects.selvage =
        { thimble, ... }:
        {
          description = "selvage-${thimble}";
          includes = [ ({ thimble, bobbin, ... }: { description = "fringe-${thimble}-${bobbin}"; }) ];
        };
      aspects.warp =
        { thimble, ... }:
        {
          description = "warp-${thimble}";
          includes = [
            (
              { thimble, ... }:
              {
                description = "weft-${thimble}";
                includes = [ ({ thimble, bobbin, ... }: { description = "tassel-${thimble}-${bobbin}"; }) ];
              }
            )
          ];
        };
    })
  ];
  inherit (tree.config) aspects lambdas;
  doorOver =
    ls:
    genRules.mkApply {
      lambdas = ls;
      inherit cnf;
      declared = D;
    };
  door = doorOver lambdas;
  poisoned = doorOver (
    builtins.mapAttrs (
      _: r: r // { fn = _: throw "gen-demo C174: an outer closure was re-applied"; }
    ) lambdas
  );
  src = k: inputs.gen.lib.substrate.identity.hashIdentity "entity" [ "name" ] (_: k);
  rel = genAspects.instancesFor (cnf // { ref = door; }) aspects {
    suppliers.${src "pewter"}.thimble = "pewter";
    containment = { };
    scopes.loom = {
      members = [
        "selvage"
        "warp"
      ];
      sources.thimble = src "pewter";
    };
  };
  vertexOf = a: rel.vertices.${builtins.head rel.reaches.loom.${a}};
  # the deferred bobbin node: the outer's include at depth 1, the middle's at depth 2
  deferred = {
    selvage = builtins.head (vertexOf "selvage").entry.includes;
    warp = builtins.head (builtins.head (vertexOf "warp").entry.includes).includes;
  };
  fireAt =
    a: scope: bobbin:
    (genAspects.instanceOf (cnf // { ref = poisoned; }) {
      aspect = "c174-${a}-deferred";
      value = deferred.${a};
      context = {
        thimble = "pewter";
        inherit bobbin;
      };
      sources = {
        thimble = src "pewter";
        bobbin = src bobbin;
      };
      inherit scope;
    }).entry;
  bobbins = [
    "linen"
    "silk"
    "wool"
  ];
  ok = v: (builtins.tryEval (builtins.deepSeq v true)).success;
  per = a: {
    scoped = map (b: (fireAt a (vertexOf a).scope b).description) bobbins;
    unscopedThrows = map (b: !(ok (fireAt a { } b))) bobbins;
  };
in
{
  c174Selvage = per "selvage";
  c174Warp = per "warp";
}
