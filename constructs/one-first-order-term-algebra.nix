# ── C137 — one first-order term algebra (den-hoag-lwbb1; ADR-0008 :150, ADR-0013 row 2, ADR-0034). A
# clause is a condition term and a body term. The body may read a coordinate only if a POSITIVE atom
# of the condition covers it (Apt-Blair-Walker's covering axiom), checked at declaration over the
# body's DERIVED reads; under a declared coordinate set an absent coordinate makes its atom FALSE
# (Clark completion) and an undeclared one is ill-formed. The term mints through the hub's one mint.
{ genAlgebra, inputs }:
let
  T = genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity;
  inherit (T.term)
    has
    always
    attrs
    concat
    lit
    readCtx
    ;
  basteDeclared = [
    "thimble"
    "bobbin"
  ];
  basteClause = {
    condition = has "thimble";
    body = attrs {
      description = concat [
        (lit "baste-")
        (readCtx "thimble" [ ])
      ];
    };
  };
  fireAt =
    context:
    let
      env = {
        inherit context;
        declared = basteDeclared;
      };
      c = T.resolveTerm env basteClause.condition;
    in
    if c ? left then
      c
    else if c.right then
      T.resolveTerm env basteClause.body
    else
      { right = null; };
in
{
  basteChecked = T.checkClause { declared = basteDeclared; } basteClause;
  basteFired = fireAt { thimble = "brass"; };
  basteAbsent = fireAt { bobbin = 1; };
  basteUnsafeChecked = T.checkClause { declared = basteDeclared; } (
    basteClause // { condition = always; }
  );
  basteUndeclaredChecked = T.checkClause { declared = basteDeclared; } (
    basteClause // { condition = has "thimbel"; }
  );
  basteReads = T.readCtxHeads basteClause.body;
  basteIdentity = genAlgebra.identityOf basteClause.body;
}
