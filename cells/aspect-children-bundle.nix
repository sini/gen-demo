# `a-nodes-children-are-one-include-with-one-identity` — aspect-children-bundle. `p` and `q` include
# loom's bundle: one node, a root, whose members are loom's walk children (`gate`, a guard leaf,
# among them). `frock` receives every child once, fired `gate` included; `smock`, reaching the bundle
# twice, receives each child once; `plainHost`, reaching `loom` only, receives loom's own content. A
# host that does not reach the bundle never reads `trap`'s throwing content, and `frock` does. The
# bundle id is asserted by its shape (its `name` position is a store path). Red where the bundle is a
# node per site, drops the guard leaf, reorders, or forces a child's content.
{
  asserts,
  childBundleFacts,
  childBundleStitches,
  childBundleLazy,
}:
let
  f = childBundleFacts;
  first = l: if builtins.isList l && l != [ ] then builtins.head l else "<none>";
  pB = first f.includesOf.p;
in
{
  construct = [ "a-nodes-children-are-one-include-with-one-identity" ];
  check = asserts (
    builtins.match "@/includes/.*" pB != null
    && first f.includesOf.q == pB
    &&
      (f.includesOf.${pB} or null) == [
        "loom/gate"
        "loom/warp"
        "loom/weft"
      ]
    && (f.parentOf.${pB} or "<none>") == null
    && f.includesOf.plain == [ "loom" ]
    &&
      childBundleStitches == {
        frock = [
          "gate"
          "warp"
          "weft"
        ];
        smock = [
          "gate"
          "warp"
          "weft"
        ];
        plainHost = [ "loom" ];
      }
    &&
      childBundleLazy == {
        plainHost = [ "loom" ];
        frock = "REFUSED";
      }
  );
}
