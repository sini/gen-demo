# gen-demo

**The acceptance corpus for [gen](https://github.com/sini/gen).**

gen-demo is a consumer, not a library. It contains no library code of its own, takes the gen hub as
its only input of note, and drives that hub the way den v2 will drive it: through the published
surface (`flakeModules.default`, `flakeModules.genLibs`), with no direct pin on any `gen-*` member.

It belongs to **no framework, no fleet and no real machine**. Nothing here is a configuration anybody
runs. It exists so that an integration error between landed gen components reads RED in a repository
whose only job is to notice, rather than surfacing later inside a framework where the cause is three
layers away.

**The growth rule:** the corpus grows **one declaration per landed component, in the same landing.**
A component that lands without changing or adding the declaration that exercises it has not been
shown to integrate.

This is v1 — one declaration per ruled construct: six positive constructs (C1-C6), the incremental
plane's byte-parity cell (T2b), and five planted-violation refusals (T5), against
`gen-specs/gen-demo/2026-09-08-v1-constructs-spec.md` in den-ag-design.

**v1.1** adds nine more positive constructs (C7-C15) and six more planted-violation refusals (T5 rows
6-11), against `gen-specs/gen-demo/2026-09-09-v1.1-coverage-spec.md` in den-ag-design. C7 rode
gen-view's own unlanded work (W1) and landed once that work reached the hub; see `## v1.1` below.

Bead: `den-hoag-gen-demo-constructs-0k3ix`.

## What v1 declares

Four nodes across two kinds, three declared edges, one policy program admitting a fourth (dynamic)
edge, a binding node, a movement, a delivery to one target through two registries, and the
incremental plane's decision crossing.

| construct                                                 | ADR                 | what it is here                                                                                                                                                                                                                                                                                                                       |
| --------------------------------------------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C1 -- kinds and nodes                                     | 0012                | two kinds (`thimble`, `bobbin`), four nodes (`pewter`, `damask`, `grosgrain`, `faille`)                                                                                                                                                                                                                                               |
| C2 -- edges, queried                                      | 0012, 0019          | `declaredEdges` plus C5's dynamic edge, ONE graph, one named query (`tacks*piping*`)                                                                                                                                                                                                                                                  |
| C3 -- a binding node                                      | 0016                | `basting:pewter:grosgrain`, minted at pass 1 over two pass-0 relata                                                                                                                                                                                                                                                                   |
| C4 -- a movement                                          | 0010, 0024          | a `selvage` channel walked on `tacks`, Λ read off C3's own relata names                                                                                                                                                                                                                                                               |
| C4b -- element identity                                   | 0024 arm F          | a diamond mints exactly one element (`diamondMoved`); a collision of identical content across three declarations mints three (`collisionMoved`); a competition key that reads the diamond's own residual admission state SPLITS the one element and refuses by name (`splitKeyed`), live control on `entityOf` keyed by scope instead |
| C5 -- a policy program                                    | 0020, 0022, 0033    | a stable model admitting `piping:grosgrain:faille`, which becomes C2's dynamic edge                                                                                                                                                                                                                                                   |
| C6 -- a delivery                                          | 0028                | one `nixos` class realized on `pewter`; two Rider limbs (`welt`, `gusset`) that must NOT realize                                                                                                                                                                                                                                      |
| C7 -- the well-definedness gate                           | 0008 §3, 0030, 0019 | `genView.boundedWellDefinedSchedule` over `config.declaredEdges` (NOT C2's `edges`), contracted through `genGraph.mkNodeRef`/`mkDeclaredEdges`; the Check reads fields of the returned `gated`, never of its argument                                                                                                                 |
| T2b -- byte parity                                        | 0008                | `compose`/`override` warm arm byte-identical to a cold `compose`, guarded by `trace.mode`                                                                                                                                                                                                                                             |
| C8 -- the contribution protocol                           | 0012, 0014          | `genAssemble.assemble`/`union` over three contributions; shape unions commutatively, content folds by positional authority                                                                                                                                                                                                            |
| C9 -- a SHARE class                                       | 0028                | `genClass` partitions declared content on `weave`, never on the kind boundary; core, gate and invariance all checked                                                                                                                                                                                                                  |
| C10 -- stratified dispatch                                | 0019                | `genDispatch` rules whose stratum is STAMPED by `deriveGroup` from their own declared `produces`, none written by hand                                                                                                                                                                                                                |
| C11 -- a federated packaged subgraph                      | 0011 §4, 0027       | `genLink.link {sources; wire;}` with a per-origin `keySemantics`; the declared capability survives the exchange                                                                                                                                                                                                                       |
| C12 -- a derived product graph + policy-stratum promotion | 0016 rulings 1-2    | `genProduct.productN "cartesian"` over two graphs; the promoted cell joins C1's nodes, C2's edges, C5's own `mdl`                                                                                                                                                                                                                     |
| C13 -- `foldLayers`                                       | 0017                | `genAlgebra.record.foldLayers`, all three strategies plus the default channel in one call                                                                                                                                                                                                                                             |
| C14 -- the closed body-term algebra                       | 0013 row 2, 0023    | `genBind.crossing.term`, a literal `TargetId`; three refusal arms carried as data in the same check cell                                                                                                                                                                                                                              |
| C15 -- a cyclic stratum, solved                           | 0008 §2, 0033       | `genMemo.runScc` over a two-member SCC with a higher-stratum dependency, deliberately outside C2's acyclic edge set                                                                                                                                                                                                                   |
| C16 -- the aspect graph, assembled                        | 0012, 0010 §3       | the corpus's own aspect facts (`genAspects.graphFacts`) contributed through `genAssemble`'s protocol alongside the node registry's membership dimension; queried through both gen-graph's labelled graph and gen-select's context                                                                                                     |
| C16b -- a foreign reference                               | 0011, 0012, 0014    | `genAspects.keyRef "mill/stitch"` on `aspects.bartack.includes`, published in `foreignIncludesOf` and never as a `declares` edge; total over every node, including the one declaring none                                                                                                                                             |
| C17 -- option-set closure                                 | 0016 ruling 5, 0033 | an `extraModules` option on `thimbles` (`shirring`) that is real declared content and CANNOT be an identity key; `thimbles.pewter.id_hash` byte-identical to the stamp minted before it existed                                                                                                                                       |
| C18 -- a kinded contribution                              | 0012, 0011          | the same node set assembled through BOTH paths -- C1's direct `genScope.buildRoots` call and `genAssemble.assemble` with `kinds` routed as a call parameter -- asserted IDENTICAL; `kinds` still refused as an eighth contribution key                                                                                                |
| C19 -- the discrete/monotone separation                   | 0019, 0020, 0012    | `discreteCtx` clears a two-node cycle's declared in-flight accessors at gen-select's seven non-monotone positions (Datafun's split); `not`/`attrs`/`when` refuse against the writable cycle, `has`/`parentMatches` still answer                                                                                                       |
| C20 -- the product adapter's totality doors, real data    | 0035, 0025 item 1   | `adapters.product.mkContext`'s `coordsFor`, wired to C12's real `seamSpace.product.coordsOf`; an under-applied `coordsFor` over the SAME real space now refuses at construction instead of writing a residual function into `__coords`                                                                                                |
| C21 -- the stamp survives the relocation                  | 0016 ruling 7, 0033 | the corpus's `thimble` composed the retired way (`imports = [ config.schema.hank ]`) and the relocated way (`inherits = [ "hank" ]`, gen-schema's staged `evalSchema`) mints one `id_hash`; dropping the inheritance MOVES it, which is what makes the equality non-vacuous                                                           |
| C22 -- a bounded extent peer-read                         | 0026                | gen-bind's `mkSystemTerminal` adapter over a real `genDelivery.realize`; one node carries an invented mark admitting no label, and its handed `specialArgs.nodes` is bounded to empty while the mark is named on every withheld peer                                                                                                  |
| C23 -- `attrs` is a nullary container strategy            | 0014, 0027          | an `attrs` option undefined and defaultless resolves to `{ }` instead of throwing, and two modules contributing disjoint keys are unioned rather than collided; the type stated a checker and nothing else before den-hoag-241d7                                                                                                      |
| C24 -- the value-injection interim, priced                | 0023 (b)            | `injectAdapter`'s declared opt-out read from the CONSUMING side: a substrate closure (gen-schema's `__functor`) crosses into `_module.args` and is still applicable there, while a substrate-written DATA position crosses plain -- the matched control that stops the first arm passing for the wrong reason                         |
| T5 -- planted refusals                                    | 0025                | thirteen enforcers, each driven red by name via `refusals`                                                                                                                                                                                                                                                                            |

`gen-modules/corpus.nix` holds the C1-C6 declarations plus C16's own tree growth; `aspect-cnf.nix`
holds the key-category declaration that both the tree and the hub read; `flake.nix` holds the
queries, C7's gate over `config.declaredEdges`, C8-C18's own standalone fixtures, and all thirty-three
`checks`, including its own `construct-index` cell over this file's two indices; `ci/refusals.sh`
holds T5's by-name half, which runs out of band because
`builtins.tryEval` cannot read a refusal's message.

### The naming rule — invented kinds only

**gen names no entities.** There is no host, user, system, machine or service in the substrate, so a
corpus that declared one would be asserting a vocabulary gen does not have and quietly importing a
framework's model into gen's acceptance criteria. Every kind, node and aspect name here is therefore
a nonsense word: `thimble`, `bobbin`, `pewter`, `damask`, `grosgrain`, `faille`, `stitch`, `welt`,
`gusset`, `basting`. No den vocabulary appears anywhere.

**The one exception is gone.** The node registry used to be spelled `hosts`, because the hub called
gen-delivery's `project` without a `selectHosts` and a registry under any other name projected
**empty** — no error, no output, just an empty `nixosConfigurations`. The hub now takes the attribute
path from the consumer (`gen.nodeRegistryPath`, ADR-0035), so both registries here are invented and
each is the plural of its own kind: `thimbles`, reached THROUGH the hub, and `bobbins`, reached by
C6's extra `project` call with an explicit `selectHosts`. See *Findings* below.

## The CI contract

`nix flake check` runs thirty-three checks, and they are the acceptance criteria:

01. **`graph-query`** — C1 + C2, both doors. gen-scope registers the two kinds and four nodes;
    gen-graph's named query walks `tacks*` then `piping*`; gen-select's second door is read with an
    explicit per-id `kindFor` over the heterogeneous node union.
02. **`binding-node`** — C3. The binding minted, identified by its own labelled relata.
03. **`movement`** — C4. The movement's value, and Λ read off C3's own relata names by construction.
04. **`policy-edge`** — C5. The policy program's stable model, total, and the derived edge admitted.
05. **`delivery-projection`** — C6. The node set, the one collected class, both Rider limbs absent
    from the classes despite both being present in the aspect body, and the bobbin door under an
    invented name.
06. **`warm-parity`** — T2b. The warm decision byte-identical to a cold one, with the guard
    (`trace.mode == "warm"`) included.
07. **`nixos-instantiate`** — the target instantiated, **not built**: the check writes
    `nixosConfigurations.pewter.config.system.build.toplevel.drvPath` to a file, which runs the whole
    NixOS evaluation and stops at the `.drv`.
08. **`contribution-protocol`** — C8. Three contributions unioned; the node set is fixed under
    permutation, the positionally-folded `spool` is not.
09. **`share-class`** — C9. The partition on `weave`, the core's shared keys and values, the gate on
    a real member, and the invariance check all in one cell.
10. **`stratified-dispatch`** — C10. Each rule's stratum stamped by `deriveGroup`; the `sateen` rule
    not firing against a `linen` context is the discriminator.
11. **`federated-link`** — C11. The locally-declared capability equals what the requirer resolves to
    after the exchange (ADR-0027's equivalence survival).
12. **`product-promotion`** — C12. The product's own `dims` order, its cells, the promoted edge set,
    a projection, and the policy program's admission of the promoted head, all read off one
    `seamCoords` rather than restated.
13. **`layered-fold`** — C13. All three `foldLayers` strategies plus the default channel in one call.
14. **`body-term-algebra`** — C14. The resolved term, `knownFormers`, the crossing's primitives and
    inert budget, and all three refusal arms as data — the one construct whose refusals live in this
    cell rather than in `refusals`.
15. **`cyclic-stratum`** — C15. `runScc`'s iterate-from-bottom ascent over a two-member SCC with an
    external `higherStrata` dependency, which the acyclic rebuilder cannot express at all.
16. **`well-defined-schedule`** — C7. `genView.boundedWellDefinedSchedule` over `config.declaredEdges`,
    read off fields of the returned `gated` record, never of its argument: the cyclic-SCC filter
    (`[ ]`, over a real five-way partition) and the contracted accessor's own edge lookup
    (`gated.edges "pewter"`). A hand-written record of the same fields satisfies this cell byte-for-
    byte -- see Oracle 1b and `refusals` row 11 below.
17. **`aspect-contribution`** — C16. The corpus's own aspect facts (`genAspects.graphFacts`)
    contributed through `genAssemble`'s protocol alongside the node registry's declared membership;
    the labelled graph `genGraph.labeledFrom`/`forgetLabels` produces and the selector context
    `genSelect.adapters.registry.mkContext` builds over the PUBLISHED parent, both walked; oracle 5's
    structural-helper substitution armed at C16's own non-flat assembly (`children`/`subtreeOf`
    diverge) and at C1's flat one (the node set does not).
18. **`aspect-foreign-reference`** — C16b. The corpus declares a FOREIGN reference —
    `genAspects.keyRef "mill/stitch"`, a third position on `aspects.bartack.includes` — and the cell
    asserts it is published as a REFERENCE and never as an edge: present in
    `c16Facts.foreignIncludesOf` in the declaration's own `{ origin; path; key; }` shape, absent from
    `c16Facts.includesOf`, and every `declares` edge in the assembled contribution naming a member of
    its `vertices`. `aspect-cnf.nix` sets no `providerPrefix`, so this corpus's origin is `[ ]` and
    the sugar's first segment `mill` makes the reference foreign by construction. The population is
    stated because it IS one: three declared positions accounted for exactly once each across the
    three relations — one checked edge, one inline body, one foreign reference — over six vertices
    and one `declares` edge, with the totality control that a node declaring no foreign reference is
    PRESENT with an empty list rather than absent. The declaration was UNDECLARABLE before
    gen-aspects `3b6d41d`: the reference entered `includesOf`, became a `declares` edge to a
    non-member, and `genAssemble`'s `requireDeclaredMembership` refused the whole contribution by
    name.
19. **`option-set-closure`** — C17, and `den-hoag-9l26n`'s corpus arm in the same cell. The `thimbles`
    registry carries an `extraModules` option (`shirring`); the cell asserts the option really landed
    AND that `thimbles.pewter.id_hash` is byte-identical to
    `thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a`, the stamp minted
    before it existed. Equality alone would pass for a registry that dropped the caller's modules, so
    both halves are load-bearing. It also pins `_identityKeys == [ "name" "spool" ]`, and that
    `identityHashForKind` — the SOLE recompute path — agrees with that stamp on this kind, whose
    `options` attribute is EMPTY because it is declared through gen-aspects' `schemaOption`. Live
    control in the same cell: `bobbin` recomputes to its own stamp over a different option set, and
    the two stamps differ. And the WRONG-kind arm, which Finding 5 recorded as absent until the
    accessor was guarded: recomputing `bobbin` against a thimble instance answers `null`, so a
    `findFirst` over candidate kinds passes over it rather than aborting.
20. **`kinded-contribution`** — C18. The same facts assembled by BOTH paths: C1's direct
    `genScope.buildRoots` call, and `genAssemble.assemble` with that same three-kind registry routed
    as `kinds`. The cell asserts the two records are IDENTICAL — `nodes`, `nodeOrder` and the
    registry all have to agree — with a negative control on the same comparator that changes one
    node's kind and reads false, and it reads the kinds back through the same `nodesOfType` door C1's
    own queries use, so the equality is not two sides equally empty. It also asserts `kinds` is still
    NOT an eighth contribution key: offered on a contribution it is refused by name. C1 could not be
    written through the protocol before `gen-assemble` `d08cebf`, which is what Finding 4 recorded.
21. **`seam-head-provenance`** — C12c, den-hoag-eh6x8. Owner-overridden standing guard: the other
    Oracle 3 rows guard a VALUE a cell already reads, and a value assertion cannot tell "`seamHead`
    computed from `seamCoords`" apart from "`seamHead` restated as the same literal" — both evaluate
    to `"seam:pewter:grosgrain"`. This cell reads no value; it reads the corpus's own `flake.nix`
    source for the one line binding `seamHead` and requires it to interpolate BOTH
    `seamCoords.thimble` and `seamCoords.bobbin`. A literal has no such line and reds this cell by
    name while leaving every value cell — including `product-promotion` — unmoved, because the
    literal and the derivation produce the identical string.
22. **`frayed-dangling-includes-refused`** — den-hoag-lk06. A local includes entry naming a key
    absent from the registry is refused by gen-link's `rewrite.originStamp`, catchably, rather than
    aborting past `tryEval` as an interpreter "attribute missing". gen-aspects synthesizes a key for
    any bare attrset placed in `includes` regardless of what the author wrote there, so an anonymous
    entry and a named-but-wrong-key one are one class; `frayed` links alone, never joining the
    mill/loom federation's sources, for the isolation reason given at its declaration.
23. **`monotone-separation`** — C19, den-hoag-0hwn. `discreteCtx` clears a context's declared
    `ctx.inFlight` accessors at gen-select's seven non-monotone positions (Datafun's discrete/monotone
    split, applied at evaluation time since gen has no type-level ∆/Γ to clear instead). A two-node
    fixture over `adapters.registry.mkContext` exercises the writable cycle at both seeds: `not`,
    `attrs` and `when` refuse catchably when the accessor they would read is declared in flight, while
    a frozen ctx, the monotone `has`, and `parentMatches` over the untouched `parent` accessor all
    still answer — the class is the read an accessor is put to, not the tag carrying it. A9 (the
    refusal is actionable) is not asserted here; it is a pairing on `ci/refusals.sh` instead, since
    `tryEval` exposes only `success`, never the thrown text.
24. **`movement-element-identity`** — C4b, den-hoag-2vzn. `diamondMoved`'s two-route arrival to
    `grosgrain` mints exactly ONE element (`value == [ "cambric" ]`, no refusal under
    `tieSet = refuse`); `collisionMoved`'s three declarations of identical content — two authored at
    `grosgrain`, one at `faille` — mint three, because element identity is the declaration coordinate
    `(producer, ordinal)` and never the content or the path that reached it. Both arms defeat the
    same two maskers: an asymmetric admission and a `labelOrder` with every letter in one layer.
25. **`registry-split-key-refuses`** — C4b, den-hoag-2vzn. Named for `registry` and not for
    `movement`, because `compositions.movement`'s key is a constant and cannot reach the spanning
    refusal at all. `splitKeyed` reads the diamond's own residual admission state as its competition
    key, so the one authored element at `grosgrain` survives under two keys and refuses catchably, by
    name — live control in the same cell: the identical declaration keyed on `c.scope` instead
    evaluates and carries exactly one contribution.
26. **`product-adapter-totality`** — C20, den-hoag-4kh.53.52. Two arms, one real `gen-product`
    coordinate graph (C12's own `seamSpace`/`seamCell`, not a mock): the working arm's real
    `coordsOf` flows through `adapters.product.mkContext`'s `coordsFor` unchanged; the armed arm
    swaps in the SAME `coordsOf`, deliberately under-applied by one argument, and now refuses
    (named throw, `tryEval`-caught) instead of writing a residual function into `__coords` that
    every downstream coord-selector match would have read as a silent, wrong `false`.
27. **`corpus-stamp-relocation-invariant`** — C21, den-hoag-ppv0z. The EQUALITY half. A `thimble`
    composed the RETIRED way (`imports = [ config.schema.hank ]`, read live off the tree being
    declared) and the RELOCATED way (`inherits = [ "hank" ]`, resolved by gen-schema's staged
    `evalSchema` pass) mint the SAME `id_hash`, over the corpus's real instrument — gen-aspects'
    own `schemaOption`, `mkInstanceRegistry`, and C17's `extraModules` inlet. Relational, never a
    literal digest: the digests this pair was designed against were measured at another lock, and
    asserting one here would relay a figure across a rev boundary. The retired arm is APPARATUS,
    not a survival of the migrated class — the reference value has to be built the old way or
    there is nothing for the new way to be compared against.
28. **`corpus-stamp-no-inherit-discriminator`** — C21, den-hoag-ppv0z. The PERTURBATION half, and
    what stops the cell above being two agreeing arms. The same staged tree with the parent
    dropped mints a DIFFERENT stamp, so the equality is non-vacuous: the instrument is shown to
    discriminate on the exact axis the equality asserts. The perturbed arm lands on
    `thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a` — the corpus's own
    published stamp, the one `ci/refusals.sh` row 13 pins — which is what shows the instrument is
    the corpus's and not a lookalike. Each cell was driven RED independently while the other
    stayed green: dropping the `inherits` built-in from `evalSchema` reds the equality alone, and
    making the parent's option non-identifying reds this one alone.
29. **`extent-peer-bounded`** — C22, den-hoag-gcr8x. `grommet` carries the `batting` mark, which
    admits no label, so its handed `specialArgs.nodes` is bounded to empty; `bodkin` and `awl` carry
    no mark and are handed the whole class, including themselves (the relation carries self-loops).
    The withheld half is read straight off the adapter — bypassing `realize` — because ADR-0026's one
    stated requirement on a consuming implementation is that a boundary refusal NAME the mark that
    caused it, and `realize`'s own carriage never surfaces a withheld set at all.
30. **`attrs-undefined-yields-empty`** — C23, den-hoag-241d7. An `attrs` option with no definition
    anywhere and no `default` resolves to `{ }`. Reads the VALUE and never a `tryEval` bit: a repair
    that yields `null`, or a nested shape, still "succeeds", and only an equality catches it.
31. **`attrs-unions-disjoint-contributions`** — C23, den-hoag-241d7. Two modules contributing
    disjoint keys to one `attrs` option both survive. The empty value alone does not buy this — a
    type can state an empty and still state no fold — so this is the container strategy's second
    half and not a restatement of the cell above.
32. **`injection-payload-price`** — C24, den-hoag-9ivu. ADR-0023 (b)'s declared interim, read from
    the side that pays for it. gen-bind's `injectAdapter` states that substrate-built values carrying
    genuine functions cross into the target's `_module.args`, inert only because the consuming module
    system never type-walks that position; this cell is the consumer confirming it on its OWN composed
    values — gen-schema's `__functor` crosses and is still applicable here, plain data crosses
    verbatim, and a substrate-written data position is plain, which is the control that stops the
    first arm passing for the wrong reason. Sites 1 and 4 of the same interim are not declarable in
    any corpus: their own text records that no shipped Adapter reaches them.
33. **`construct-index`** — this file's own two indices, checked against the live `checks` attrset
    rather than against each other. Two hand-maintained surfaces recorded the same construct set —
    this numbered list, and the `## What v1 declares` table above — and drifted twice in three
    landings because each repair fixed the one it was looking at (`den-hoag-bl06m`). The cell asserts
    the numbered list's own names equal `builtins.attrNames` of the evaluated `checks` attrset, and
    that the table's rows equal the construct labels this list attributes each check to, plus T5 (the
    one construct with no check cell); both comparisons report how many entries they scanned against
    how many they expected, never a bare pass.

T5's thirteen refusals are not among these thirty-three: `builtins.tryEval` yields `success` and nothing
else, so a refusal's message is unreadable to any `checks.default` cell (`den-hoag-9mo`). They run by
name through `refusals` instead (below).

**T5's standing gate is the workflow, not a check cell.** Neither `check-lock` nor `check-hub-main`
runs `ci/refusals.sh` — a refusal's message is unreadable to any `checks.default` cell, which is the
whole reason this half runs out of band. So `.github/workflows/ci.yml` runs it as its own step, and
the spec's ruled default (OPEN 2: *"Default: `just refusals`"*) is now scheduled rather than left to
someone running it by hand. `ci/tests/refusals-pairing.nix` gates the other half: a row that loses
its planted or unplanted arm reds `nix flake check ./ci` even though the script itself would still
exit 0 on the arms it kept.

### Two arms, plus the by-name half

These are devshell commands, declared in `ci/flake.nix` beside the `ci`, `fmt` and `repl` that
gen-harness supplies. `direnv` loads them from `.envrc`; without it, `nix develop ./ci`.

```sh
check-lock            # nix flake check
check-hub-main        # nix flake check --refresh --override-input gen github:sini/gen
refusals              # T5's thirteen planted violations, each driven red by name, each with an unplanted control
```

The committed `flake.lock` is the **last-green pin**. The second arm evaluates the same corpus against
the hub's **current main**, so a hub landing that breaks the corpus reads red immediately instead of
waiting for a relock.

The full build of the target is **not** a check — it is verified once at delivery and on demand:

```sh
build-target          # nix build .#nixosConfigurations.pewter.config.system.build.toplevel
```

## Findings against the hub

Recorded here because an acceptance corpus that swallows what it finds is not one.

**1. RESOLVED at the current pin.** v0 recorded `nix flake check` RED at hub `d6ec9c8` because the
hub's pinned `gen-merge` (`8722a23`) refused every aspect declaration
(`` gen-merge: the option type `aspectsRoot' supplies a `functor' this boundary cannot read … ``); the
fix was one commit ahead, at `gen-merge` main `0c11b23`. v1 relocks to hub main
`9497f49d83d9aacecbc38e6bc627f39abea787d4`, which pins `gen-merge` at exactly `0c11b23`, and both
arms are measured green at that pin. No workaround was needed here — the repair was the hub's own
relock, as v0 predicted.

**2. The hub hardcoded the node-registry name — REPAIRED.** `flakeModules/default.nix` called
`genDelivery.project` with no `selectHosts` and exposed no option for one, so a consumer's node
registry had to be named literally `hosts`, and a wrong name failed **silently** — an empty
projection, not an error. It was the same family as the two defects that module's own header records
as carried unfixed (`den-hoag-es9g`): the class-name hardcode and the witness-2 gap. Fixed under
ADR-0035 (`den-hoag-hub-hardcodes-hosts-mxpd5`): the hub takes the attribute path from the consumer,
and this corpus declares `gen.nodeRegistryPath = [ "thimbles" ]`. The sibling output key
`gen.composed.hosts` is the same finding at another site and is **not** fixed here.

**3. Two stale docs, met while building, still stale at the v1 pin.** gen-scope's README documents
`eval { roots = …; }`; the formal argument is `scope`, and `buildNodes` is a tombstone that refuses
its own name — `buildRoots` is the live constructor. gen-aspects' `mkAspectModule` comment says it
declares `options.aspects` and `options.schema` together; it declares only `options.aspects` —
`gen-modules/corpus.nix` declares `options.schema` itself, from the same `aspectSchema` value, for
exactly this reason.

**4. RESOLVED, and C18 now carries the assembly the finding said was unwritable.** v1.3 recorded that
`gen-assemble` had a `types` contribution key it could never honour: `assemble` forwarded no `kinds`
to `buildRoots`, so any non-empty `types` on any contribution aborted the assembly
(`gen-scope.buildRoots: \`types\` declares kind(s) … but no \`kinds\` registry was supplied`) — measured on both a populated and an all-null `types`value, with only an absent`types`green. That put the corpus's own C1 outside the protocol: it calls`genScope.buildRoots`directly with a three-kind registry because it had no other way to give a node a kind, which is the duplication the toolkit exists to remove. The all-null arm was a second defect and named a kind the author had not declared —`union`'s fold answered `{ }`for an id every layer passed over, and`{ }`is not`null\`,
so the substrate read it as a declared kind.

**`kinds` is still NOT among the seven contribution keys, and that clause stands** — offered *on* a
contribution it is refused by name against the same seven, which C18 asserts. What changed is where
it is offered: the repair is `gen-assemble` `d08cebf`, relocked here, which routes `kinds` as a
parameter of the `assemble` CALL, beside `strategies` and `strict`. The split is fact against
vocabulary — a `types` entry is what one layer says about one node, so it folds by position; a kind
registry carries the `below` relation every kind is ranked in, so it is one per assembly. The same
landing stops the fold minting `{ }` from an absence, for both content families. C18 declares the
same facts by both paths — the direct `buildRoots` call C1 already makes, and `assemble` with a
`kinds` registry — and asserts the records are IDENTICAL, with a negative control that changes one
node's kind and reads false on the same comparator. The design question this finding reported to
`den-hoag-9wj6` is answered there and specified in
`specs/2026-09-11-gen-assemble-types-protocol-gap-spec.md`. C16 still declares no `types` and carries
its per-node data through `decls` alone; it no longer has to.

**5. RESOLVED, and C17 now carries the arm whose absence was the finding.** v1.3 recorded that
`identityHashForKind` ABORTED where its own documented contract promises a miss: recomputing the
`bobbin` kind against a `thimble` instance died on `attribute 'gauge' missing`, an uncatchable
interpreter error from an unguarded `(k: instance.${k})`, where the DISCOVERY PROPERTY promises a
reliable *"not this kind"*. gen-schema's own `test-discriminates-kind` could not see it — its two
candidate kinds declare IDENTICAL option sets and so never reach a key the instance lacks — and C17
therefore carried no wrong-kind arm. The repair is
`gen-schema` `b7de7391f81d5a3f05bea3985e6a662da81634f4`, relocked here: the accessor is guarded on
PRESENCE and the codomain is `identity | null`, so a candidate the instance cannot belong to answers
`null` and a `findFirst` over candidate kinds passes over it. C17 asserts exactly that —
`identityHashForKind c17Bobbin c17Pewter == null` — beside the right-kind recompute it already
carried. The guard is presence-only by design, so a candidate whose identity key the instance
*carries* at a value the mint refuses still propagates the mint's named refusal; that one is the
mint's own ADR-0034 behaviour and is catchable, unlike the abort removed here.

## v1.1

Nine more positive constructs (C7-C15), one new `checks` cell per construct, and six more
planted-violation refusals (T5 rows 6-11, `refusals`), against
`gen-specs/gen-demo/2026-09-09-v1.1-coverage-spec.md` in den-ag-design. C12 interleaves into C1/C2/C5
rather than standing alone: its promoted node joins C1's node set, its promoted edges join C2's edge
set, and its own third policy declaration is admitted or refused by the *same* `mdl` C5 already
built — the discriminator the spec names (seeding `productN "tensor"` in place of `"cartesian"`)
drives exactly that promotion path red.

**C7 landed in this pass.** It rides gen-view's own W1 work (`boundedWellDefinedSchedule`,
ADR-0008 §3), unreachable until the hub relocked to carry it; the relock is the commit ahead of
this one. C7 gates `config.declaredEdges` directly -- not C2's `edges`, which additionally carries
C5's policy-produced dynamic edge and C12's promoted coordinate edges -- so the corpus makes one
graph claim and two doors read different sets from it. Its Check reads fields of the returned
`gated` record, never of its argument: a cell over the argument would force gen-graph alone (already
reached) and add nothing for gen-view (gate v0's CONSTRUCTION-1, `den-hoag-xgu75`). `refusals`
row 10 plants the cycle `pewter -> grosgrain -> damask -> pewter`; row 11 hands the gate a
hand-assembled attrset carrying the same `index`/`dependencies` fields `mkDeclaredEdges` builds, no
`_type` tag -- `genGraph.isDeclaredEdges` is purely nominal, so this door is the only
construct-granular witness a hand-written stand-in cannot forge (Oracle 1b).

### The roster census

The corpus's growth rule is "reached" against `gen/lib/mkGenLibs.nix`'s roster (22 top-level keys;
`strata` is that roster's own bucket-lookup map, not a library, so 21 libraries). "Reached" is judged
by **evaluation**: a roster member is reached iff forcing the corpus's `.#checks.<system>` cells
actually evaluates through its `lib` — not by a name appearing in this repo's text, and not by a
library merely being bound (e.g. as a `specialArgs` value) without anything calling it.

Measured by poisoning each roster member's `lib` with a run-unique `throw` and forcing every
`.#checks.<system>` cell, exits read unpiped: a member is reached iff at least one cell reds under its
own poison. Reproduce against a copy of this repo with one roster member's `lib` swapped for a
throwing stub, then force every `.#checks.<system>.<cell>`'s **evaluation** with `nix flake check`
(`check-lock` wraps it) — expect it to print `running 0 flake checks` and build nothing: the asserts
sit in each derivation's argument, so evaluating is what forces the poison, not building.
`gen-settings` poisoned is the discriminating negative control: every cell stays green (rc 0), showing
the instrument discriminates and this corpus simply has nothing that forces `gen-settings`.

- **Before this landing:** 14 of 21 — unreached: `algebra`, `assemble`, `class`, `dispatch`, `link`,
  `product`, `settings`.
- **After this landing:** 20 of 21 — unreached: `settings` only.
- **Deferred by ruling, not by omission:** `settings`. ADR-0017 (owner-ruled 2026-08-06, amended
  2026-08-24) retires the `gen-settings` library itself; what survives re-homes as a framework-level
  **feature**, and "the retirement's EXECUTION is deferred, no work scheduled by the ruling." There
  is no settings construct for this corpus to declare against until that execution lands.

## v1.2

One more positive construct (C16) and one more planted-violation refusal (T5 row 12, `refusals`), against `2026-09-09-gen-demo-aspect-contribution-spec.md` in den-ag-design. C16
assembles the corpus's **own** aspect graph through `genAssemble`'s contribution protocol
(ADR-0012, ADR-0010 §3 toolkit item): `genAspects.graphFacts` publishes the corpus's aspect nodes,
its containment relation and its includes relation as plain data, and two contributions —
the aspect facts and the node registry's declared membership — are unioned into one assembly.
Both gen-graph's labelled graph (`labeledFrom`/`forgetLabels`, walked with `query`, `roots`,
`leaves`, `cycles`) and gen-select's selector context (`adapters.registry.mkContext`, built over the
PUBLISHED parent) are exercised over the result, and oracle 5's structural-helper substitution is
armed a second way: at C16's own non-flat assembly, where `children`/`subtreeOf` diverge between the
hand-written and toolkit forms, beside C1's flat one, where the node set does not move at all.

`refusals` row 12 plants the aspect includes contribution under the reserved label `I` —
gen-scope's own import relation between scopes, not the aspect includes relation, and reaching for
it because the words are near neighbours is exactly the collision `gen-assemble`'s reserved-label
refusal exists to stop.

**The roster census is unchanged by this landing: 20 of 21, `settings` unreached.** C16 calls no
roster member C1-C15 did not already reach — `assemble` (C8), `scope`, `graph` and `select` are all
already forced by earlier cells — so this landing moves nothing in the census above.

## v1.3

One more positive construct (C17) and one more planted-violation refusal (T5 row 13, `refusals`), against `2026-09-09-gen-option-set-closure-spec.md` in den-ag-design. Between them they
declare the two halves of ONE property — an entity's identity is a function of its KIND's option set
(ADR-0016 ruling 5), and that set closes at a boundary rather than drifting with whatever the
fixpoint happened to gather (ADR-0033).

**C17 is the half that is a construction, so it is asserted as a VALUE.** The `thimbles` registry now
carries an `extraModules` option, `shirring`, which is real declared content on every thimble. It
cannot be an identity key and could not be made one: the key set closed at the kind boundary, one
stratum above the instance submodule, before any module named in `extraModules` was seen. The
contribution is not refused — it is unexpressible in an identity, which is why there is nothing here
for a by-name row to catch. `thimbles.pewter.id_hash` is byte-identical to the stamp the corpus carried
before `shirring` existed, and the cell pins that literal rather than comparing two things the same
edit would move.

**T5 row 13 is the half that has no construction, so it is a refusal — and it is a WARM RE-COMPOSE.**
Within one evaluation a kind's option set simply is what it is; the move is only nameable where TWO
evaluations are in hand, and the substrate holds two in exactly one place, `warmFrom`. So the row
builds the prior evaluation and the warm re-compose in a single expression, which is what makes a
by-name refusal reachable from one `nix eval` at all. A COLD plant would exit 0 on both arms and
measure nothing. The two arms are one token apart: `internal = true` leaves the planted `grommet` a
decl-side contribution that re-merges `id_hash` and moves no identity, and the unplanted arm's exact
stdout is the corpus's own unmoved stamp — so a refusal keyed on decl-side dirtiness alone, which
would destroy reuse for every consumer, fails that arm.

The refusal is `gen-memo`'s, over a fact `gen-merge` computes: the evaluator holds both evaluations
and hands two maps of coordinate to minted identity to the incremental plane, which admits with an
empty moved set or throws naming the coordinate, the kind, both identities and the contributing
declarations.

**`den-hoag-9l26n` closes on C17's cell.** On a kind declared through gen-aspects' `schemaOption` —
the shape this corpus uses — the kind value's `options` attribute is EMPTY, so the sole recompute path
used to answer over `[ "name" ]` alone and disagree with the stamp on every instance of it. Measured
at this landing's two pins, same probe, same corpus shape:

|                                      | recompute                                                                  | carried stamp       | agree     |
| ------------------------------------ | -------------------------------------------------------------------------- | ------------------- | --------- |
| hub `0c53726` (gen-schema `88c41cb`) | `thimble:500c2f78da6c6e81d7b62dbd6944eaebe9f46b566e5adbb2d5553ad023218020` | `thimble:d3dc9389…` | **false** |
| hub `6421d65` (gen-schema `168cf21`) | `thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a` | `thimble:d3dc9389…` | **true**  |

**The stamp itself did not move**, which is the other thing worth reading off that table: the closure
changed which derivation produces the key set, not the key set. All seventeen prior cells evaluate to
byte-identical `drvPath`s across the relock.

**The roster census is unchanged by this landing: 20 of 21, `settings` unreached.** Measured, not
assumed: `gen-settings` poisoned with a run-unique throwing stub leaves every cell green (rc 0), so
nothing C17 adds forces it. Live control in the same run: `gen-schema` poisoned reds the run and the
poison's own token appears in the output, so the instrument is not dead. C17 calls only `schema`,
which C1 already forced.
