# `inspect-carries-the-policy-edge` — C25 over C5's policy half. The subject's `model` is C5's
# gen-program result record, gen-inspect's documented form, so the piping edge is in the IR with a
# rule origin whose derivation is C5's piping rule.
{
  asserts,
  c25PolicyIr,
  pipingHead,
  seamHead,
}:
{
  construct = [ "C25" ];
  check = asserts (
    {
      rule = map (e: "${e.label}:${e.src}:${e.dst}") (
        builtins.filter (e: e.origin.kind == "rule") c25PolicyIr.facts.edges
      );
      heads = map (d: d.rule.head) c25PolicyIr.facts.origins."piping:grosgrain:faille".derivations;
    } == {
      rule = [
        "piping:grosgrain:faille"
        "bobbin:${seamHead}:grosgrain"
        "thimble:${seamHead}:pewter"
      ];
      heads = [ pipingHead ];
    }
  );
}
