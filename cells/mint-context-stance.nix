# `mint-context-stance` — C53, den-hoag-8lu00. The ONE mint's stance on string CONTEXT, exercised
# through the published surface with a store path the corpus already holds (`inputs.gen`'s
# outPath, which carries context without building anything). Context is not identity-bearing
# (ADR-0016 ruling 4 via ADR-0034): a string and its `==` context-free twin mint one identity at
# the value, kind and label positions, and no identity carries context. The kind identity used to
# carry the store path's context (and abort as an attribute name), and a context-carrying label
# used to abort the mint uncatchably.
#
# C53 -- den-hoag-8lu00. The stance this pins is DEFAULTED, REVERSIBLE: it executes ADR-0034 as
# written, and den-hoag-kunjm (whether a dedup decision is context-sensitive) is unruled; a kunjm-B
# ruling re-opens den-hoag-8lu00 and this cell with it. Live control: the last conjunct — two
# distinct values mint apart.
{ asserts, inputs }:
{
  construct = [ "C53" ];
  check = asserts (
    let
      mint = inputs.gen.lib.substrate.identity.hashIdentity;
      ctx = inputs.gen.outPath;
      plain = builtins.unsafeDiscardStringContext ctx;
      z = builtins.substring 0 0 ctx;
      kindId = mint "spindle${z}" [ "name" ] (_: "flax");
    in
    builtins.hasContext ctx
    && mint "spindle" [ "name" ] (_: ctx) == mint "spindle" [ "name" ] (_: plain)
    && !(builtins.hasContext kindId)
    && kindId == mint "spindle" [ "name" ] (_: "flax")
    && mint "spindle" [ "name${z}" ] (_: "flax") == mint "spindle" [ "name" ] (_: "flax")
    && mint "spindle" [ "name" ] (_: "flax") != mint "spindle" [ "name" ] (_: "linen")
  );
}
