# `option-set-closure` — C17, and `den-hoag-9l26n`'s corpus arm in the same cell. The `thimbles`
# registry carries an `extraModules` option (`shirring`); the cell asserts the option really landed
# AND that `thimbles.pewter.id_hash` is byte-identical to
# `thimble:c286677c4bce2e1032da87c5bb7e2e6f26fef1450accceb38f8bce67cbd9a159`, the stamp minted
# before it existed. Equality alone would pass for a registry that dropped the caller's modules, so
# both halves are load-bearing. It also pins `_identityKeys == [ "name" "spool" ]`, and that
# `identityHashForKind` — the SOLE recompute path — agrees with that stamp on this kind, declared
# through gen-aspects' `schemaOption`, whose `options` publishes the plane an instance imports
# (`aspects`, `spool`) and whose `refs` is empty. Live
# control in the same cell: `bobbin` recomputes to its own stamp over a different option set, and
# the two stamps differ. And the WRONG-kind arm, which Finding 5 recorded as absent until the
# accessor was guarded: recomputing `bobbin` against a thimble instance answers `null`, so a
# `findFirst` over candidate kinds passes over it rather than aborting.
#
# C17 — the identity-key set is CLOSED at the kind boundary, so an option contributed on
# the instance side has nowhere to attach in an identity. The corpus's `thimbles` registry
# now carries an `extraModules` option (`shirring`); this asserts the option is really
# there AND that the stamp is byte-identical to the one the corpus carried before it
# existed. Both halves are load-bearing: the equality alone passes for a registry that
# dropped the caller's modules on the floor, which is a different library and a worse one.
#
# It also closes den-hoag-9l26n. `identityHashForKind` is the SOLE recompute path, and on
# a kind declared through gen-aspects' `schemaOption` — the shape this corpus uses, whose
# declarations live in the module its `__functor` imports — it used to answer over `[ "name" ]` alone and disagree
# with the stamp on every instance. Since the derivation reads the kind's own evaluation
# it cannot disagree, and the pinned literal is what separates agreement from two
# derivations degenerating together.
#
# The live control is the OTHER kind: `bobbin` recomputes to its OWN stamp, over a
# different option set, and the two stamps differ — so the recompute is neither constant
# nor degenerate. (The gen-schema-DECLARED kind-value shape is controlled in gen-schema's
# own suite, `identity-key-closure.test-control-both-kind-value-shapes-mint-alike`; this
# corpus declares no such kind and inventing one here would test the fixture, not the
# corpus.)
#
# ★ THE WRONG-KIND ARM IS PRESENT, AND IT IS THE HALF KIND DISCOVERY ACTUALLY RUNS ON.
# `id-hash.nix`'s DISCOVERY PROPERTY says a recompute that does not match the carried
# hash means the kind guess is wrong, and a `findFirst` over candidate kinds reaches
# that case on nearly every candidate. Recomputing `bobbin` against a thimble instance
# answers `null` — *not this kind* — because a thimble carries none of `bobbin`'s
# identity keys; `null` is not an identity, so the loop passes over it instead of
# dying. This arm used to be absent and the absence was reported as a finding: the
# accessor was unguarded and this expression aborted `attribute 'gauge' missing`, an
# uncatchable interpreter error where the contract promises a value. The guard is
# presence-only by design, so a candidate whose key the instance CARRIES at a value the
# mint refuses still propagates the mint's named refusal — a different terminal state,
# owned by the mint, and catchable. This corpus exercises the absent-key half, which is
# the one discovery iterates over.
{
  asserts,
  c17Bobbin,
  c17Pewter,
  c17Schema,
  c17Thimble,
  genValues,
}:
{
  construct = [ "C17" ];
  check = asserts (
    c17Pewter.shirring == "gathered"
    && c17Pewter.id_hash == "thimble:c286677c4bce2e1032da87c5bb7e2e6f26fef1450accceb38f8bce67cbd9a159"
    &&
      c17Pewter._identityKeys == [
        "name"
        "spool"
      ]
    &&
      builtins.attrNames c17Thimble.options == [
        "aspects"
        "spool"
      ]
    && c17Thimble.refs == { }
    && c17Schema.identityHashForKind c17Thimble c17Pewter == c17Pewter.id_hash
    &&
      c17Schema.identityHashForKind c17Bobbin genValues.bobbins.grosgrain
      == genValues.bobbins.grosgrain.id_hash
    && genValues.bobbins.grosgrain.id_hash != c17Pewter.id_hash
    && c17Schema.identityHashForKind c17Bobbin c17Pewter == null
  );
}
