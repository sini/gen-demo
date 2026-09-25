# `identity-regimes` — C56, den-hoag-3f39. gen-algebra's intensional identity under ADR-0034,
# composed with the hub's ONE mint (`substrate.identity.hashIdentity`) rather than a stub: the
# encoder `mkIntensional` over a `basting` registry and `conservativeEq`.
#
# The five `checks` items (the two throw-refusals, `revision` required and a lambda in `args`, are
# `ci/refusals/row77-78.sh`):
#   1. the MINT carries the relation, not the name — one coordinate mints one identity, differing
#      `args` mint two, and the two carry EQUAL names;
#   2. the registry coordinate is in the preimage — one `(ctor, args)` under two `revision`s mints
#      apart, names equal again. Its negative arm (same members, same revision, different builder
#      bodies ⇒ ONE identity) is undiscriminable by any builtin and is a declared residue, not a
#      cell: asserting the merge would be asserting the defect;
#   3. the SEALED regime decides where the producer's refusal is the `__id` accessor — and ONLY
#      there: a refusal under an ordinary key surfaces, catchably, beside inert controls that decide
#      both ways, so the cell separates "`__id` is excluded" from "every key is". A
#      self-referential payload aborts the evaluator uncatchably and no cell can hold it;
#   4. the search runner is RETIRED (den-hoag-b7u1v): gen-algebra publishes no `search`, so no key
#      site reads the regime outside the regime's own readers;
#   5. the UNMIGRATED regime decides on content, not the name — one program point, one shared `fn`,
#      differing inert `closure` ⇒ unequal, while an equal closure still identifies. It is the
#      witness of ADR-0034's deleted name arm: a gen-algebra that still decides an unmigrated pair on
#      `name` alone calls this pair equal.
{
  asserts,
  genAlgebra,
  inputs,
}:
let
  inherit (genAlgebra)
    mkIntensional
    conservativeEq
    identityOf
    regimeTagOf
    ;
  mint = inputs.gen.lib.substrate.identity.hashIdentity;

  basting = {
    revision = "r1";
    members = {
      whipstitch = args: (v: s: s);
      backstitch = args: (v: s: s);
    };
  };
  mk = mkIntensional mint basting;
  mkR2 = mkIntensional mint (basting // { revision = "r2"; });

  madder = mk "whipstitch" { thread = "madder"; };
  madder' = mk "whipstitch" { thread = "madder"; };
  woad = mk "whipstitch" { thread = "woad"; };
  idOf = v: (identityOf v).minted;

  # Sealed values the encoder cannot produce: hand-built, sharing ONE base and overriding ONE key,
  # because Nix `==` compares values in name order with a pointer fast path — two independently
  # built records differ at `__functor` before any payload is reached.
  sealed = {
    name = "whipstitch";
    closure = { };
    fn = v: s: s;
    __functor = self: self.fn;
    __mint.unmintable = {
      reason = "a lambda in an identity position";
      ctor = "whipstitch";
    };
  };
  # Unmigrated values: no `__mint`, no `__id`; overridden the same way, and for the same reason.
  unmigrated = {
    name = "whipstitch";
    closure.thread = "madder";
    fn = v: s: s;
    __functor = self: self.fn;
  };
  sealedEq = a: b: conservativeEq (sealed // a) (sealed // b);
  decides = e: (builtins.tryEval e).success;
in
{
  construct = [ "C56" ];
  check = asserts (
    # 1 — the mint, not the name
    madder.name == woad.name
    && idOf madder == idOf madder'
    && idOf madder != idOf woad
    && conservativeEq madder madder'
    && !(conservativeEq madder woad)
    # 2 — the registry coordinate
    && madder.name == (mkR2 "whipstitch" { thread = "madder"; }).name
    && idOf madder != idOf (mkR2 "whipstitch" { thread = "madder"; })
    # 3 — the sealed regime: the `__id` arm decides, an ordinary-key refusal surfaces
    && regimeTagOf (identityOf sealed) == "s"
    && sealedEq { __id = throw "identity: no mintable identity"; } {
      __id = throw "identity: no mintable identity";
    }
    && !(decides (sealedEq { zz = throw "plain"; } { zz = throw "plain"; }))
    && sealedEq { zz = "v"; } { zz = "v"; }
    && !(sealedEq { zz = "v"; } { zz = "w"; })
    # 4 — the search runner is retired (den-hoag-b7u1v): no key site outside the regime readers
    && !(genAlgebra ? search)
    # 5 — the unmigrated regime: same name, differing closure, unequal
    && regimeTagOf (identityOf unmigrated) == "u"
    && !(conservativeEq unmigrated (unmigrated // { closure.thread = "woad"; }))
    && conservativeEq unmigrated (unmigrated // { closure.thread = "madder"; })
  );
}
