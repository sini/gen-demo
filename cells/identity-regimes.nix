# `identity-regimes` — C56, den-hoag-3f39. gen-algebra's intensional identity under ADR-0034,
# composed with the hub's ONE mint (`substrate.identity.hashIdentity`) rather than a stub: the
# encoder `mkIntensional` over a `basting` registry, `conservativeEq`, and the key site reached the
# only way a consumer can reach it, through `search.converge`.
#
# The four `checks` items (the two throw-refusals, `revision` required and a lambda in `args`, are
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
#   4. the KEY site keys on the identity, not the name — two continuations at one program point
#      with differing `args` BOTH fire. Items 1–3 stay green on a build whose dedup key reads the
#      name; this one drops a continuation there.
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
    search
    ;
  mint = inputs.gen.lib.substrate.identity.hashIdentity;

  basting = {
    revision = "r1";
    members = {
      whipstitch = args: (v: s: search.emit [ "${args.thread}:${v}" ] s);
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
  sealedEq = a: b: conservativeEq (sealed // a) (sealed // b);
  decides = e: (builtins.tryEval e).success;

  converged =
    f1: f2:
    (search.converge (search.on "k" f2 (search.on "k" f1 (search.insert "k" "v" search.empty))))
    .results;
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
    # 4 — the key site: both continuations fire; the same value twice dedups to one
    &&
      converged madder woad == [
        "madder:v"
        "woad:v"
      ]
    && converged madder madder == [ "madder:v" ]
  );
}
