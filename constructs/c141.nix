# ── C141 — a gen-aspects guard is a first-order term (den-hoag-lwbb1 unit 2) ──
#
# A guard is a condition term and a body term of gen-algebra's ONE algebra, checked where it meets its
# cnf and keyed by the mint over the two. Three declarations:
#
# - `c141Tuck`, a first-order guard whose body READS the coordinate its condition guards (`has
#   thimble`, then `readCtx thimble`), so the body needs no closure;
# - `c141Pleat`, a guard NESTED in another guard's body, which stays a guard through the outer's
#   firing and fires at its own;
# - `c141DoorNode`, a door node: its body is a reference that the framework's door (`cnf.ref`)
#   resolves at a context, with that context's sources. The door here is the corpus's stub of the
#   framework side; gen-rules supplies the real one (unit 4).
{
  genAspects,
  genAlgebra,
  genMerge,
  inputs,
}:
let
  hashIdentity = inputs.gen.lib.substrate.identity.hashIdentity;
  T = genAlgebra.term hashIdentity;
  t = T.term;
  inherit (genAspects) guard pred;
  outerId =
    (T.refId {
      declared = {
        site = "gusset";
        reads = [ "thimble" ];
      };
    }).right;
in
{
  c141Tuck = guard (pred.has "thimble") {
    description = t.concat [
      (t.lit "tuck-")
      (t.readCtx "thimble" [ ])
    ];
  };
  c141Pleat = guard pred.always { sub = guard (pred.class "nixos") { description = "pleat"; }; };
  c141DoorNode = guard (pred.has "thimble") (t.ref outerId);
  # The declared set (`thimble`, an entity kind) and the stub door, which answers the one
  # registration with an output keyed on the context it is handed.
  c141Cnf = {
    entityKinds.thimble = true;
    ref =
      {
        id,
        context,
        sources,
        captured,
      }:
      {
        right = {
          output.description = "gusset-${context.thimble}";
          scope = { };
        };
      };
  };
  c141Source = n: hashIdentity "entity" [ "name" ] (_: n);
  # A guard placed at an aspect position of gen-aspects' own schema under `cnf`, where it is checked.
  c141Place =
    cnf: defs:
    let
      s = genAspects.mkAspectSchema (cnf // { keySemantics.nixos.category = "class"; });
    in
    (genMerge.evalModuleTree {
      modules = [
        { options.schema = s.schemaOption; }
        (s.mkAspectModule { })
        { config.aspects = defs; }
      ];
    }).config.aspects;
}
