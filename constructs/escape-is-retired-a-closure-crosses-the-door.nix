# ── C159 — the escape is retired; a closure crosses the door (den-hoag-lwbb1 unit 3, U3r; design
# Section 5, "retirements last"). One rule closure, written three ways. As gen-program's declared
# escape it is refused by name, `policy-body/escape-retired`, and so is the escape's firing path;
# handed to `admit` as a hand-rolled record it is not the normal form and is refused
# `policy-body/skeleton-malformed`, never checked and admitted. Written at a rule position of a framework surface and lowered by gen-rules'
# `defunctionalize`, the same closure becomes a door rule over `ref`, and gen-program's
# `groundInstances` fires it through the door within the contract the escape used to declare.
{
  genRules,
  genProgram,
  genMerge,
}:
let
  D = [ "thimble" ];
  contract = {
    emits = [ "selvage" ];
    binds = [ "weft" ];
    suppresses = [ ];
  };
  tack =
    { thimble, ... }:
    [
      {
        ctor = "member";
        kind = "selvage";
        payload.weft = thimble;
      }
    ];
  escapeRecord = contract // {
    name = "tack";
    fn = tack;
  };
  cnf = {
    entityKinds = D;
    moduleArgs = { };
  };
  load = genRules.defunctionalize {
    inherit cnf;
    declared = D;
    key = "gen-demo:c159";
    lambdasPath = [
      "bench"
      "lambdas"
    ];
    rulePaths = [
      {
        path = [
          "bench"
          "rules"
        ];
        inherit contract;
      }
    ];
  };
  bench = genMerge.evalModuleTree { } [
    {
      options.bench.rules = genMerge.mkOption {
        type = genMerge.lazyAttrsOf genMerge.raw;
        default = { };
      };
      options.bench.lambdas = genRules.lambdas;
    }
    (load { bench.rules.tack = tack; })
  ];
  door = genRules.mkApply {
    lambdas = bench.config.bench.lambdas;
    inherit cnf;
    declared = D;
  };
in
{
  c159Escape = genProgram.escape escapeRecord;
  c159FireEscape = genProgram.fireEscape escapeRecord { thimble = "brass"; };
  c159Admitted = genProgram.admit escapeRecord;
  c159DoorFired =
    genProgram.groundInstances
      {
        sources.thimble = "entity:" + builtins.hashString "sha256" "thimble";
        inherit door;
      }
      { thimble = "brass"; }
      (
        genProgram.body {
          name = "tack";
          declared = D;
          clauses = [ bench.config.bench.rules.tack ];
        }
      );
}
