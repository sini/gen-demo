# `closure-door` — C142. A closure guard and a closure rule, lowered at the loader, cross through the
# one door: the guard's node is a door node over `ref`, it fires reading `bobbin` past its formals and
# never sees the undeclared `stray`; the rule fires within its contract. A conditional edge holds with
# its condition and is defeated by its abnormality: without `unless` it would hold in both.
{
  asserts,
  c142HemNode,
  c142HemFired,
  c142WeaveFired,
  c142PleatHeld,
  c142PleatDefeated,
}:
{
  construct = [ "closure-door" ];
  check = asserts (
    (c142HemNode.__guard or false)
    && c142HemNode.body.__bodyTerm == "Ref"
    && c142HemFired == { description = "hem-linen"; }
    &&
      map (d: builtins.removeAttrs d [ "__mint" ]) c142WeaveFired == [
        {
          ctor = "member";
          kind = "selvage";
          payload.weft = "pewter";
        }
      ]
    && builtins.elem "pleat:bolt" c142PleatHeld.trueAtoms
    && builtins.elem "pleat:bolt" c142PleatDefeated.falseAtoms
  );
}
