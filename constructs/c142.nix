# ── C142 — the closure door (gen-rules; design Section 4). One closure guard and one closure rule,
# both written to a framework surface and lowered by `defunctionalize` at the loader: each becomes a
# first-order door node or door rule whose body is `ref r`, and the closure is registered under `r`.
# The guard is `{ ... }@args`, read past its formals, and receives the context restricted to the
# declared coordinates (`stray` is not one). The rule fires through gen-program's `groundInstances`
# within its declared contract. Beside them, a conditional edge held by its condition and defeated by
# an abnormality, solved in the well-founded model (Przymusinski 1988, Example 9).
{
  genRules,
  genProgram,
  genAspects,
  genMerge,
  genAlgebra,
  inputs,
}:
let
  T = genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity;
  t = T.term;
  D = [
    "thimble"
    "bobbin"
  ];
  cnf = {
    entityKinds = D;
    keySemantics.nixos.category = "class";
    aspectModules = [ (genRules.lambdasMount "lambdas") ];
    moduleArgs = {
      config = true;
      pkgs = true;
      lib = true;
      options = true;
      modulesPath = true;
      aspect = true;
    };
  };
  load = genRules.defunctionalize {
    inherit cnf;
    declared = D;
    key = "gen-demo:c142";
    lambdasPath = [
      "loom"
      "lambdas"
    ];
    aspectPaths = [
      [
        "loom"
        "aspects"
      ]
    ];
    rulePaths = [
      {
        path = [
          "loom"
          "rules"
        ];
        contract = {
          emits = [ "selvage" ];
          binds = [ "weft" ];
          suppresses = [ ];
        };
      }
    ];
  };
  loom = genMerge.evalModuleTree { } [
    {
      options.loom.aspects = genMerge.mkOption {
        type = genMerge.lazyAttrsOf genMerge.raw;
        default = { };
      };
      options.loom.rules = genMerge.mkOption {
        type = genMerge.lazyAttrsOf genMerge.raw;
        default = { };
      };
      options.loom.lambdas = genRules.lambdas;
    }
    (load {
      loom.aspects.hem =
        { ... }@args:
        {
          description = if args ? bobbin then "hem-${args.bobbin}" else "hem";
        };
    })
    (load {
      loom.rules.weave =
        { thimble, ... }:
        [
          {
            ctor = "member";
            kind = "selvage";
            payload.weft = thimble;
          }
        ];
    })
  ];
  door = genRules.mkApply {
    lambdas = loom.config.loom.lambdas;
    inherit cnf;
    declared = D;
  };
  vocab = genAspects.mkGuardVocab (cnf // { ref = door; });
  src = k: "entity:" + builtins.hashString "sha256" k;
  context = {
    thimble = "pewter";
    bobbin = "linen";
    stray = "x";
  };
  sources = {
    thimble = src "thimble";
    bobbin = src "bobbin";
    stray = src "stray";
  };
  solve =
    declarations:
    genProgram.model {
      program = genProgram.program [ "bolt" ] declarations;
      interpretation = [ ];
      prior = null;
      complete = true;
    };
  pleat = genRules.conditionalEdge {
    head = "pleat:bolt";
    when = t.has "fold:bolt";
    unless = "unpicked-pleat:bolt";
    relata = [ "bolt" ];
    label = "pleats";
  };
  unpicked = genRules.abnormality {
    head = "unpicked-pleat:bolt";
    when = t.has "snag:bolt";
    relata = [ "bolt" ];
  };
  facts = map (h: {
    head = h;
    relata = [ "bolt" ];
  });
in
{
  c142HemNode = loom.config.loom.aspects.hem;
  c142HemFired = vocab.applyGuardWith {
    inherit context sources;
    scope = { };
  } loom.config.loom.aspects.hem;
  c142WeaveFired =
    genProgram.groundInstances
      {
        sources = sources;
        door = door;
      }
      context
      (
        genProgram.body {
          name = "weave";
          declared = D;
          clauses = [ loom.config.loom.rules.weave ];
        }
      );
  c142PleatHeld = solve (facts [ "fold:bolt" ] ++ pleat ++ unpicked);
  c142PleatDefeated = solve (
    facts [
      "fold:bolt"
      "snag:bolt"
    ]
    ++ pleat
    ++ unpicked
  );
}
