# ── C25 — THE GRAPH INTERROGATED, THROUGH THE HUB'S PUBLISHED FRAMEWORK BUCKET
# (den-hoag-graph-viz-viy69, ADR-0015). gen-inspect is the roster's 22nd member and the
# newest at `framework`: it materializes an assembled graph into ONE named IR and answers
# questions about it — which nodes exist and of what kind, which edges are declared, which a
# policy program produced and why, what reaches what. This corpus is a consumer of that
# surface over ITS OWN graph, which is the only way the claim "every gen consumer needs
# this" stops being a sentence.
#
# ★ REACHED AT `inputs.gen.lib.framework.inspect`, NOT AS A MODULE ARG. `flakeModules.genLibs`
# injects eight roster names and `inspect` is not among them; the stratum BUCKET is the hub's
# published path for exactly this, and a consumer that needed the hub to grow a module-arg
# line before it could reach a new member would make every roster landing a two-repository
# change. Adding the line remains available and is not needed.
{ config, inputs }:
let
  c25Inspect = inputs.gen.lib.framework.inspect;
  c25Payload = config.gen.composed.values;
  # `declaredEdges` is a LIST of `{ from; to; label; }` and the IR contract takes
  # label -> src -> [ dst ]. The fold is the corpus's, not the library's: gen-inspect takes a
  # subject already in the shape its consumer's graph has, and this is that shape for this
  # consumer.
  c25Relations = builtins.foldl' (
    acc: e:
    acc
    // {
      ${e.label} = (acc.${e.label} or { }) // {
        ${e.from} = ((acc.${e.label} or { }).${e.from} or [ ]) ++ [ e.to ];
      };
    }
  ) { } c25Payload.declaredEdges;
  # THE DEGENERATE SUBJECT: this corpus's DECLARED half, with an empty policy half. C5's
  # dynamic edge is admitted by a gen-scope program rather than a gen-program model, so the
  # policy half stays empty here and the construct is about the declared graph — an honest
  # scope, and the one whose figures this corpus already states elsewhere.
  c25Ir = (
    c25Inspect.mkInspector {
      register = {
        thimble = c25Payload.thimbles;
        bobbin = c25Payload.bobbins;
      };
      relations = c25Relations;
      program.rules = [ ];
      model = {
        trueAtoms = [ ];
        verdict = _: "false";
      };
    }
  );
  # The door, driven. `tryEval` reports THAT it refused; WHICH refusal fired is a claim about a
  # message and belongs on the plane that can read one, so this arm asserts the pair: a name
  # this graph does not carry refuses, and a name it does carry answers.
  c25Refuses = q: !(builtins.tryEval (builtins.deepSeq (c25Ir.query q) true)).success;
in
{
  inherit
    c25Inspect
    c25Payload
    c25Relations
    c25Ir
    c25Refuses
    ;
}
