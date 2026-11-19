# `warm-quotient-representative` — den-hoag-fja3w. A clean quotient attribute is served warm as the
# cold fold serves it (ADR-0008 item 2), tagged (ADR-0020 never-silence, ADR-0008 §3). `loom`'s
# `weave` ascends under key-set inclusion, a quotient carrier, and `frame` reads it through
# `getRepresentative` across a declared edge. The edit is to `spool`, unrelated to both, so
# `genMemo.warmOverride` over gen-scope's `foldEquations` calls `loom` and `frame` clean and the evaluator
# serves `weave` from the prior through `getRepresentative`. Live controls: `weave` is in `loom`'s
# served set, so the read is the serve and not a recompute; an edit to `loom` itself moves the
# representative, warm as cold.
{
  asserts,
  genScope,
  genGraph,
  genMemo,
}:
let
  engine = { inherit (genScope) foldEquations; };
  equation = name: stratum: kind: compute: {
    inherit
      name
      compute
      stratum
      kind
      ;
    readsAttrs = [ ];
  };
  equations = {
    children = equation "children" "structural" "nta" (_: _: { });
    imports = equation "imports" "structural" "synthesized" (_: _: [ ]);
    ply = equation "ply" "resolution" "synthesized" (self: id: (self.node id).decls.ply or 0);
    weave = equation "weave" "resolution" "synthesized" (
      genScope.circular
        {
          carrier = {
            bottom = { };
            leq = a: b: builtins.all (k: b ? ${k}) (builtins.attrNames a);
            height = 4;
            quotient = true;
          };
        }
        (
          self: id: prev:
          let
            n = builtins.length (builtins.attrNames prev);
          in
          if n >= (self.node id).decls.ply or 0 then prev else prev // { "warp${toString n}" = n; }
        )
    );
    frame = equation "frame" "resolution" "synthesized" (
      self: id: if id == "frame" then self.getRepresentative "loom" "weave" else null
    );
  };
  fold =
    decls:
    let
      scope = genScope.buildRoots {
        kinds = genScope.mkKinds [ (genScope.mkKind { } "host") ];
        decls = {
          loom.ply = 2;
          frame = { };
          spool.ply = 1;
        }
        // decls;
        types = {
          loom = "host";
          frame = "host";
          spool = "host";
        };
      };
    in
    genScope.foldEquations { } {
      inherit scope;
      schedule = { inherit equations; };
      declaredDependencies = genGraph.mkDeclaredEdges {
        frame = [ (genGraph.mkNodeRef (id: scope.nodes ? ${id}) "loom") ];
      };
      parseParent = _: null;
    };
  cold = fold { };
  warm = id: decls: (genMemo.warmOverride engine cold id decls).eval;
  reads = ev: {
    loom = ev.getRepresentative "loom" "weave";
    frame = ev.get "frame" "frame";
  };
  tagged = representative: {
    _type = "gen-scope/quotient-representative";
    inherit representative;
  };
in
{
  construct = [ "warm-quotient-representative-served" ];
  check = asserts (
    reads (warm "spool" { ply = 7; }) == reads (fold { spool.ply = 7; }).eval
    &&
      (warm "spool" { ply = 7; }).getRepresentative "loom" "weave" == tagged {
        warp0 = 0;
        warp1 = 1;
      }
    && builtins.elem "weave" ((warm "spool" { ply = 7; }).served "loom")
    && reads (warm "loom" { ply = 3; }) == reads (fold { loom.ply = 3; }).eval
    && reads (warm "loom" { ply = 3; }) != reads cold.eval
  );
}
