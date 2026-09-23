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

| construct                                                 | ADR                 | what it is here                                                                                                                                                                                                                                                                                                                                      |
| --------------------------------------------------------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C1 -- kinds and nodes                                     | 0012                | two kinds (`thimble`, `bobbin`), four nodes (`pewter`, `damask`, `grosgrain`, `faille`)                                                                                                                                                                                                                                                              |
| C2 -- edges, queried                                      | 0012, 0019          | `declaredEdges` plus C5's dynamic edge, ONE graph, one named query (`tacks*piping*`)                                                                                                                                                                                                                                                                 |
| C3 -- a binding node                                      | 0016                | `basting:pewter:grosgrain`, minted at pass 1 over two pass-0 relata                                                                                                                                                                                                                                                                                  |
| C4 -- a movement                                          | 0010, 0024          | a `selvage` channel walked on `tacks`, Λ read off C3's own relata names                                                                                                                                                                                                                                                                              |
| C4b -- element identity                                   | 0024 arm F          | a diamond mints exactly one element (`diamondMoved`); a collision of identical content across three declarations mints three (`collisionMoved`); a competition key that reads the diamond's own residual admission state SPLITS the one element and refuses by name (`splitKeyed`), live control on `entityOf` keyed by scope instead                |
| C5 -- a policy program                                    | 0020, 0022, 0033    | a stable model admitting `piping:grosgrain:faille`, which becomes C2's dynamic edge                                                                                                                                                                                                                                                                  |
| C6 -- a delivery                                          | 0028                | one `nixos` class realized on `pewter`; two Rider limbs (`welt`, `gusset`) that must NOT realize                                                                                                                                                                                                                                                     |
| C7 -- the well-definedness gate                           | 0008 §3, 0030, 0019 | `genView.boundedWellDefinedSchedule` over `config.declaredEdges` (NOT C2's `edges`), contracted through `genGraph.mkNodeRef`/`mkDeclaredEdges`; the Check reads fields of the returned `gated`, never of its argument                                                                                                                                |
| T2b -- byte parity                                        | 0008                | `compose`/`override` warm arm byte-identical to a cold `compose`, guarded by `trace.mode`                                                                                                                                                                                                                                                            |
| C8 -- the contribution protocol                           | 0012, 0014          | `genAssemble.assemble`/`union` over three contributions; shape unions commutatively, content folds by positional authority                                                                                                                                                                                                                           |
| C9 -- a SHARE class                                       | 0028                | `genClass` partitions declared content on `weave`, never on the kind boundary; core, gate and invariance all checked                                                                                                                                                                                                                                 |
| C10 -- stratified dispatch                                | 0019                | `genDispatch` rules whose stratum is STAMPED by `deriveGroup` from their own declared `produces`, none written by hand                                                                                                                                                                                                                               |
| C11 -- a federated packaged subgraph                      | 0011 §4, 0027       | `genLink.link {sources; wire;}` with a per-origin `keySemantics`; the declared capability survives the exchange                                                                                                                                                                                                                                      |
| C12 -- a derived product graph + policy-stratum promotion | 0016 rulings 1-2    | `genProduct.productN "cartesian"` over two graphs; the promoted cell joins C1's nodes, C2's edges, C5's own `mdl`                                                                                                                                                                                                                                    |
| C13 -- `foldLayers`                                       | 0017                | `genAlgebra.record.foldLayers`, all three strategies plus the default channel in one call                                                                                                                                                                                                                                                            |
| C14 -- the closed body-term algebra                       | 0013 row 2, 0023    | `genBind.crossing.term`, a literal `TargetId`; three refusal arms carried as data in the same check cell                                                                                                                                                                                                                                             |
| C15 -- a cyclic stratum, solved                           | 0008 §2, 0033       | `genMemo.runScc` over a two-member SCC with a higher-stratum dependency, deliberately outside C2's acyclic edge set                                                                                                                                                                                                                                  |
| C16 -- the aspect graph, assembled                        | 0012, 0010 §3       | the corpus's own aspect facts (`genAspects.graphFacts`) contributed through `genAssemble`'s protocol alongside the node registry's membership dimension; queried through both gen-graph's labelled graph and gen-select's context                                                                                                                    |
| C16b -- a foreign reference                               | 0011, 0012, 0014    | `genAspects.keyRef "mill/stitch"` on `aspects.bartack.includes`, published in `foreignIncludesOf` and never as a `declares` edge; total over every node, including the one declaring none                                                                                                                                                            |
| C17 -- option-set closure                                 | 0016 ruling 5, 0033 | an `extraModules` option on `thimbles` (`shirring`) that is real declared content and CANNOT be an identity key; `thimbles.pewter.id_hash` byte-identical to the stamp minted before it existed                                                                                                                                                      |
| C18 -- a kinded contribution                              | 0012, 0011          | the same node set assembled through BOTH paths -- C1's direct `genScope.buildRoots` call and `genAssemble.assemble` with `kinds` routed as a call parameter -- asserted IDENTICAL; `kinds` still refused as an eighth contribution key                                                                                                               |
| C19 -- the discrete/monotone separation                   | 0019, 0020, 0012    | `discreteCtx` clears a two-node cycle's declared in-flight accessors at gen-select's seven non-monotone positions (Datafun's split); `not`/`attrs`/`when` refuse against the writable cycle, `has`/`parentMatches` still answer                                                                                                                      |
| C20 -- the product adapter's totality doors, real data    | 0035, 0025 item 1   | `adapters.product.mkContext`'s `coordsFor`, wired to C12's real `seamSpace.product.coordsOf`; an under-applied `coordsFor` over the SAME real space now refuses at construction instead of writing a residual function into `__coords`                                                                                                               |
| C21 -- the stamp survives the relocation                  | 0016 ruling 7, 0033 | the corpus's `thimble` composed the retired way (`imports = [ config.schema.hank ]`) and the relocated way (`inherits = [ "hank" ]`, gen-schema's staged `evalSchema`) mints one `id_hash`; dropping the inheritance MOVES it, which is what makes the equality non-vacuous                                                                          |
| C22 -- a bounded extent peer-read                         | 0026                | gen-bind's `mkSystemTerminal` adapter over a real `genDelivery.realize`; one node carries an invented mark admitting no label, and its handed `specialArgs.nodes` is bounded to empty while the mark is named on every withheld peer                                                                                                                 |
| C23 -- `attrs` is a nullary container strategy            | 0014, 0027          | an `attrs` option undefined and defaultless resolves to `{ }` instead of throwing, and two modules contributing disjoint keys are unioned rather than collided; the type stated a checker and nothing else before den-hoag-241d7                                                                                                                     |
| C24 -- the value-injection interim, priced                | 0023 (b)            | `injectAdapter`'s declared opt-out read from the CONSUMING side: a substrate closure (gen-schema's `__functor`) crosses into `_module.args` and is still applicable there, while a substrate-written DATA position crosses plain -- the matched control that stops the first arm passing for the wrong reason                                        |
| C25 -- the graph interrogated                             | 0015, 0012          | gen-inspect reached at the hub's published `framework` bucket and materialized over THIS corpus's own graph: four nodes over two kinds and three declared edges become one IR, a SQL query answers over it, an unknown table and an unknown label value are both refused BY NAME, and the walk reports `faille` as the node no declared edge reaches |
| C26 -- kind inheritance resolves a value                  | 0016 ruling 7, 0033 | the corpus's own `dart` kind inherits `notch`'s `grade` option through the relocated pass (`inherits = [ "notch" ]`); `darts.chambray` sets only `bevel`, so `grade` resolving to `notch`'s default is the inheritance and not two defaults agreeing; a mirrored fixture with `inherits` dropped shows the same option unreachable                   |
| C27 -- rule identity refuses a name-only collision        | 0034                | two `gen-dispatch` intensional functions sharing the program-point name `notchGuard` mint no override handle from it; the no-override arm still fires both, overriding either now refuses by name                                                                                                                                                    |
| C28 -- an order mark binds a declining declaration        | 0026                | `viewRelation`'s required `orderMark`, composed with the declaration's own order as a lexicographic product, mark outer, over the corpus's real `tacks`/`gathers` edges out of `pewter`; its order declines (`$` below both arrivals) and the mark overturns it, the identity mark being the arm showing the query alone chose otherwise             |
| C29 -- a caller-supplied base module arg                  | 0033                | a kind whose module forces `argand` WHILE DECLARING an option, mounted through `mkInstanceRegistry`'s `specialArgs` and so through `attrsOf`'s rebuild of gen-merge's submodule; withholding the arg on the same kind is refused catchably, which is what makes the stock arm a statement about the channel and not about where `argand` came from   |
| C30 -- an internal nested tree reports its own orphan     | 0025 item 1         | an option typed with gen-merge's own nesting seam (`evalModuleTree`'s `.type`, not `t.submodule`) receives an undeclared key under it at `check = false`; the outer `.undeclared` names it at its full path instead of the def vanishing with `.config` silently smaller, the same key at the tree's top level being the live control                |
| C31 -- a custom guard form refuses at first use           | 0025 item 1         | gen-aspects' `mkGuardVocab` over a malformed (`reads` missing) and a core-colliding (`eq`) custom form: construction stays total, the first `applyGuard` through the vocabulary refuses though it names neither form, and a sound `fourchette` form is the control that dispatch is not refusing unconditionally                                     |
| C32 -- the warm path reports a reused tree's orphan       | 0025 item 1, 0008   | a warm `evalModuleTree` re-compose that REUSES a nesting-seam leaf (`spoolTree` in `warmDecision.reused`) names the def the nested tree dropped, and its `.undeclared` equals the cold re-evaluation's; before, the warm arm answered `[ ]` for a reused leaf                                                                                        |
| C33 -- a warm run that reuses nothing says so             | 0008                | a function-headed base re-composed warm is admitted and remerges every leaf; the hub's `trace.inert` reads `true` with `reused == [ ]`, where `mode == "warm"` alone hid it, and warm-parity's armed run reading `inert == false` is the control                                                                                                     |
| C34 -- a wrapped module keeps its importer's file         | 0025 item 1         | a def reached through `{ _file = "/demo/spool.nix"; imports = [ … ]; }` carries that file in `provenance.spool.defs`, where it used to read the engine's `<gen-merge>` fallback; the value `sateen` is asserted beside it                                                                                                                            |
| C35 -- the module reader classifies like nixpkgs          | 0025 item 1         | a shorthand key beside `imports` is config (`spool` reads `sateen`, where it read the default); a surplus key beside an explicit `config` is refused catchably, the same module without it being the control, and by name in `refusals` row 31                                                                                                       |
| C36 -- a refined option under the `mkType` arm            | 0025                | `bobbin.picks`, refined positive, on a kind built through gen-aspects' `mkType`: the kind's `refinements` name `picks`, and the registry refuses `picks = 0` by name (`refusals` row 32)                                                                                                                                                             |
| C37 -- one refined type declared twice survives           | 0034                | `bobbin.picks` declared in two modules of the staged pass with one let-bound refined type; the merge keeps exactly one refinement, read back as its message; two different refinements of one base refuse (`refusals` row 30)                                                                                                                        |
| C38 -- a function-bearing datum dedups by `==`            | 0025 item 1, 0034   | `movement-dedup-function-datum`: under `byDatum`, one module binding authored at two scopes collapses (Nix `==` is true of one binding) and a fresh literal survives; 2 kept, 1 licensed drop, where the datum used to abort uncatchably in `toJSON`                                                                                                 |
| C39 -- a nesting seam reads a definition as its reference | 0025 item 1         | `nesting-def-reading`: a function def at an `(evalModuleTree …).type` option yields `spool = "sateen"`, where it aborted uncatchably; a `submodule` declaring `key` takes the def's `key = "sateen"`, where it read the default                                                                                                                      |
| C40 -- a declaration read refuses module syntax           | 0025 item 1         | `declaredOptions` of C35's typo module (`option.weft` beside `options.spool`) is refused by name, where it answered `[ "spool" ]`; the spelled-right twin reads `[ "spool" "weft" ]`; the message is `refusals` row 35's                                                                                                                             |
| C41 -- a foreign type's check is enforced                 | 0025 item 1         | `spool` typed nixpkgs `lib.types.str` refuses `1` catchably, where gen-merge's own fold used to accept it; the same option given `sateen` is the control, and the refusal is by name in `refusals` row 36                                                                                                                                            |
| C42 -- a discharged nesting option reads its reference    | 0025 item 1         | `empty-nesting-reads-its-reference`: a `submodule` option defined only under `mkIf false` reads `weft = "plain"`, where it aborted uncatchably; a strict `attrsOf` drops the discharged `linen`, where it kept the key; with the condition true both read `"twill"`                                                                                  |
| C43 -- a module named by a path string is a module        | 0025 item 1         | `module-path-string`: a store-path string under `either (submodule M) str` is the module (`{ key = "sateen"; }`), where the union answered the string; `lint` collects that string as the engine imports it, one finding where it dropped it                                                                                                         |
| C44 -- a nested tree as a container element refuses       | 0025 item 1         | `element-tree-refuses-per-level`: a key a `check = false` tree does not declare, inside an `attrsOf` element, is refused when its level is read, where it vanished at exit 0; the same tree typed bare still reports it; the message is `refusals` row 37's                                                                                          |
| C45 -- a scope named after a package                      | 0025 item 1         | `relation-entries-store-named-scope`: a scope named `baseNameOf pkgs.hello` carries string context; gen-view keys it by its text, so the datum filed there is read back as one entry whose scope and datum keep their context, where the read used to abort (`… is not allowed to refer to a store path`)                                            |
| T5 -- planted refusals                                    | 0025                | forty enforcers, each driven red by name via `refusals`                                                                                                                                                                                                                                                                                              |

`gen-modules/corpus.nix` holds the C1-C6 declarations plus C16's own tree growth; `aspect-cnf.nix`
holds the key-category declaration that both the tree and the hub read; `flake.nix` holds the
queries, C7's gate over `config.declaredEdges`, C8-C18's own standalone fixtures, and all
fifty-seven `checks`, including its own `construct-index` cell over this file's two indices; `ci/refusals.sh`
holds T5's by-name half, which runs out of band because
`builtins.tryEval` cannot read a refusal's message.

### The naming rule — invented kinds only

**gen names no entities.** There is no host, user, system, machine or service in the substrate, so a
corpus that declared one would be asserting a vocabulary gen does not have and quietly importing a
framework's model into gen's acceptance criteria. Every kind, node and aspect name here is therefore
a nonsense word: `thimble`, `bobbin`, `pewter`, `damask`, `grosgrain`, `faille`, `stitch`, `welt`,
`gusset`, `basting`. No den vocabulary appears anywhere.

**The one exception is gone.** The node registry used to be spelled `hosts`, because the hub called
gen-delivery's `project` without a `selectNodes` and a registry under any other name projected
**empty** — no error, no output, just an empty `nixosConfigurations`. The hub now takes the attribute
path from the consumer (`gen.nodeRegistryPath`, ADR-0035), so both registries here are invented and
each is the plural of its own kind: `thimbles`, reached THROUGH the hub, and `bobbins`, reached by
C6's extra `project` call with an explicit `selectNodes`. See *Findings* below.

## The CI contract

This repository has **two check planes**, and `nix flake check` covers the one its argument names
and no other: the **root** flake's fifty-seven checks, listed below, and **`ci/`**'s six harness
cells (`default` — the batch asserter over `ci/tests` — plus `treefmt-tree-root`,
`mdformat-plugins`, `agents-md-citations`, `ci-plane-coverage`, `ci-self-input`). `check-lock` and
`check-hub-main` each run **both**, which is `den-hoag-dq6mw`: while they ran the root form alone,
a seeded red in the `ci/` plane left `check-lock` exiting 0 and printing *"all checks passed!"*, so
its green read as suite cover and was not.

The fifty-seven root checks are the acceptance criteria:

01. **`graph-query`** — C1 + C2, both doors. gen-scope registers the two kinds and four nodes;
    gen-graph's named query walks `tacks*` then `piping*`; gen-select's second door is read with an
    explicit per-id `kindFor` over the heterogeneous node union.
02. **`binding-node`** — C3. The binding minted, identified by its own labelled relata.
03. **`movement`** — C4. The movement's value, and Λ read off C3's own relata names by construction.
04. **`policy-edge`** — C5. The policy program's stable model, total, and the derived edge admitted.
05. **`delivery-projection`** — C6. The node set, the one collected class, both Rider limbs absent
    from the classes despite both being present in the aspect body, and the bobbin door under an
    invented name. gen-aspects' exported `hasClassContent` is also called directly, on both of its
    clauses: the declared-but-unset class and a fabricated empty module each read as no content.
06. **`warm-parity`** — T2b. The warm decision byte-identical to a cold one, with both guards
    (`trace.mode == "warm"` and `trace.reused == [ "ferrule" ]`) included. The second is what makes
    the equality a statement about reuse: the base is a plain attrset and `ferrule` is outside the
    edit, so the warm arm splices that leaf from the previous evaluation instead of remerging it.
    `trace.inert == false` is read too: an armed warm run is not inert, which is C33's control.
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
33. **`inspect-materializes-the-corpus-graph`** — C25, den-hoag-graph-viz-viy69. gen-inspect, the
    roster's newest `framework` member, materializes this corpus's own declared graph into the one
    named IR its contract defines: four nodes over two kinds, three edges, every one carrying a
    declaration origin because this subject has no policy half. Asserted as a record rather than as
    a count, so a materialization that lost a kind and gained a node cannot pass the arithmetic. The
    library is reached at `inputs.gen.lib.framework.inspect` — the stratum bucket the hub publishes —
    and not as a module arg, because `flakeModules.genLibs` injects eight roster names and this is
    not one of them.
34. **`inspect-answers-and-refuses-by-name`** — C25, den-hoag-graph-viz-viy69. The query surface
    answers over this graph AND the door refuses a name it does not carry, and the pair is the
    assertion rather than either half. Against a raw row source an unknown table yields `[ ]` at exit
    0, indistinguishable from "no such edge", so a refusal alone proves nothing without an answer
    beside it. Two refusals are driven: an unknown table, and an unknown LABEL VALUE — the sharp one,
    a well-formed query over a known column whose value nothing publishes. A label this graph does
    carry is the live control on the same door.
35. **`inspect-walks-the-corpus-graph`** — C25, den-hoag-graph-viz-viy69. `faille` is the node no
    declared edge reaches, which is this corpus's own stated fact about itself and what makes C5's
    dynamic edge observable elsewhere. The WALK is asked rather than the edge list: the IR's
    `perLabel` is an attrset of accessors and a wrong shape fails only on application, so a
    materialization that built the wrong one reds here and nowhere earlier. `pewter` is the control,
    reaching on both labels.
36. **`kind-inheritance-resolves-a-value`** — C26, den-hoag-0pk67. The corpus's `dart` kind
    declares `inherits = [ "notch" ]` and no `grade` option of its own; `darts.chambray` sets only
    `bevel`, so a resolved `grade == "waxed"` on the real corpus is the relocated pass composing by
    NAME (ADR-0016 ruling 7), not two defaults agreeing. A mirrored fixture with the same shape and
    `inherits` dropped shows `grade` unreachable on that arm, the check's own discriminator.
37. **`seam-identity-collision-refused`** — C27. Two intensional functions sharing the
    program-point name `notchGuard` (ADR-0034, den-hoag-t6iy2): the substrate mints no
    handle from that name, so neither rule collapses onto the other's `overridden` entry;
    the no-override arm still fires both, and overriding either one now throws
    `compose.nix`'s existing "cannot override anonymous rule" refusal by name instead of
    silently replacing whichever rule the substrate saw last.
38. **`order-mark-binds`** — C28, ADR-0026 / M9. The effective visibility order is the LEXICOGRAPHIC
    PRODUCT of a declared order mark with the declaration's own order, MARK OUTER, so a declaration
    may refine only inside the mark's ties and can neither erase nor reverse a pair the mark states.
    The fixture is the corpus's own graph — `pewter` reaches `grosgrain` on the real `tacks` edge and
    `damask` on the real `gathers` edge, read through C2's own `byLabel` accessor, with each scope's
    datum taken from the value that node really declares — and the declaration's order is written to
    DECLINE: `gathers` outranks `tacks`, and `$ = -1` puts the root's own empty path below both
    arrivals. Two arms, the same call, varying the mark alone: under the binding mark
    (`tacks` ≻ `$` ≻ `gathers`) `grosgrain`'s real `gauge` wins and BOTH the root's own path and the
    query-preferred arrival are shadowed; under the identity mark the product degenerates and
    `pewter` keeps its real `spool`. The second arm is what makes the first a statement about the
    mark rather than about a library that happened to prefer `tacks`. Resolved values on both arms,
    never the presence of the field: `orderMark` is required and total, so a cell that only observed
    it reaching the call would be green on a build that dropped it from the product entirely. The
    optional step in `(tacks|gathers)?` is load-bearing — dropping the `?` un-admits the root's own
    empty path and there is no decline left to overcome.
39. **`movement-dedup-equality`** — C4b, den-hoag-behm0. A dedup decides on the relation its own
    constructor DECLARES, never on an encoding of it: `dedups.byDatum` says "structural equality on
    the datum itself", and structural equality in Nix is `==`. Two arms on `collisionGraph`'s shape,
    differing in one token. The reference's three identical data collapse 3 → 1 and record two
    drops, both licensed — that arm is what keeps the cell from being a `dropped == 0` check, which
    would pass the subject the moment the library over-corrected into refusing every dedup. The
    subject wraps one datum as `{ outPath = "cambric"; }`, which Nix `==` calls distinct from
    `[ "cambric" ]` and `builtins.toJSON` encodes identically to it: a dedup keyed on the encoding
    keeps ONE contribution and writes a `dropped` record asserting a duplicate that does not exist,
    so the caller is told two values were the same about two values that are not. The declared
    relation keeps TWO and records the one drop that is real. The oracle is read off the result
    alone, since `viewRelation` carries its `definition` inside the answer.
40. **`instance-base-module-arg-reaches-a-kind`** — C29, den-hoag-jyiji. A kind's modules receive a
    base module argument the CALLER supplied (`denful/den#687`). A module that forces an argument
    while DECLARING an option cannot be served from `_module.args`: reading that forces the config
    fixpoint the module is part of, and the abort is an infinite recursion naming neither the module
    nor the argument, with no `tryEval` door. So the cell asserts the CHANNEL and never the symptom —
    an oracle whose red state hangs the runner instead of failing it is not an oracle. It declares
    through `mkInstanceRegistry`, which is the idiom a consumer writes and which builds its element
    as `attrsOf (mkInstanceType …)`, so the args cross `attrsOf`'s rebuild on the way in; a submodule
    whose rebuild re-entered the args-less constructor would drop them silently and leave this green
    over a channel that reached nothing. The discriminator is the same kind with `specialArgs`
    withheld: refused, and catchably, so the stock arm is a statement about the inlet rather than
    about where `argand` happened to come from.
41. **`internal-tree-reports-its-orphan`** — C30, den-hoag-1ksl. An option typed with gen-merge's
    own nesting seam (another `evalModuleTree` call's `.type`, not `t.submodule`), both levels at
    `check = false`, receives a key its inner tree does not declare. The outer `.undeclared` names it
    at its full path and `.config` is exactly the declared part; before, the def vanished at exit 0.
    The same key at the tree's own top level is the control that the report was already live there.
42. **`guard-vocab-eager`** — C31, den-hoag-cr72. A custom guard form missing `reads`, and one
    shadowing the core `eq` form, each still CONSTRUCT a vocabulary and each refuse on its first
    `applyGuard` call, though that call dispatches `always` and never names the bad form. A sound
    invented form (`fourchette`) constructs and dispatches beside them, so the refusals are not
    `applyGuard` refusing everything.
43. **`warm-reused-tree-reports-its-orphan`** — C32, den-hoag-warm-path-still-discards-mw5t6.
    C30's seam on the WARM path: a re-compose that reuses a leaf typed with gen-merge's nesting seam
    reports the def its nested tree dropped, equal to a cold re-evaluation of the same modules. The
    leaf's presence in `warmDecision.reused` is asserted, so a warm run that remerged it through the
    cold arm cannot pass the cell for the wrong reason.
44. **`warm-inert-says-so`** — C33, den-hoag-0t9oh. The function-headed T2b base this corpus
    shipped before `c544488`: its warm run is admitted (`trace.mode == "warm"`) and reuses nothing,
    because gen-merge rules every function module dirty. `trace.inert == true` beside
    `trace.reused == [ ]` is what now says so; `mode` alone read "warm" and hid it.
45. **`wrapped-module-provenance-file`** — C34, den-hoag-sdml-file-loss-2xeet. A definition passed
    through an unattributed `{ _file; imports }` wrapper is attributed to the wrapper's file in
    `provenance`, not to gen-merge's `<gen-merge>` fallback, and the merged value is read beside it.
46. **`module-reader-syntax`** — C35, den-hoag-s7826. gen-merge reads a module's keys the way
    nixpkgs' `unifyModuleSyntax` does. A shorthand key beside `imports` is config: `spool` reads
    `sateen`, where the key used to be dropped unread and the option kept its default. A surplus key
    beside an explicit `config` is refused, beside the same module without that key reading
    `sateen`, so a reader refusing every module cannot pass; the message is `refusals` row 31's.
47. **`mktype-refinements`** — C36, den-hoag-mx07b. `bobbin` is built through gen-aspects'
    `mkType` arm, and its refined `picks` option is named in the kind's `refinements`, which the arm
    used to publish as a literal `{ }` so that the registry enforced nothing. The instance value is
    read beside it; the refusal of `picks = 0` is `refusals` row 32.
48. **`refined-redeclaration-survives`** — C37, den-hoag-refined-inherits-base-mint-oqrvg.
    `bobbin.picks` is declared in two modules of the staged pass with one let-bound refined type, and
    the kind's `refinements.picks` carries exactly one message. The kind's `.options` is not a read
    path (C17 pins it empty). Two different refinements of one base are `refusals` row 30.
49. **`movement-dedup-function-datum`** — C38, den-hoag-eunp3. A NixOS module is a function,
    and `dedups.byDatum` used to address a datum with `toJSON`, which aborts on a lambda where
    `tryEval` cannot hold it. Step 8 now gives every lambda one tag in the bucket address and leaves
    the decision to `==`: `cambricModule`, one binding at `grosgrain` and `faille`, collapses, while a
    fresh `{ config, ... }: { }` literal at `faille` survives. Two kept, one drop, and `noFalseDedup`
    holds.
50. **`nesting-def-reading`** — C39, den-hoag-za4hp. gen-merge's two nesting types read a
    definition the way their nixpkgs references do. The tree type `(evalModuleTree …).type` reads
    every def as a module, so a function def yields `spool = "sateen"`, where it used to abort
    uncatchably; `types.submodule` reads an attrset def as config, so an option it declares as `key`
    takes `sateen`, where the key was dropped as module identity and read the default.
51. **`declaration-read-syntax`** — C40, den-hoag-4kw63. gen-merge refuses a module's syntax on
    each door's first read, which for `declaredOptions` is the declaration stratum. C35's typo
    module, read for its declarations only, is refused by name, where the read used to answer
    `[ "spool" ]` and drop `weft` without a word. The spelled-right twin reads `[ "spool" "weft" ]`
    beside it; the message is `refusals` row 35.
52. **`foreign-type-check`** — C41, den-hoag-foreign-leaf-check-unenforced-v4h7k. A type stated in
    the foreign protocol has its `check` applied to every definition before gen-merge's own fold, as
    nixpkgs' `mergeDefinitions` does. `spool` typed `lib.types.str` used to accept `1`; it is now
    refused, beside the same option reading `sateen`; the message is `refusals` row 36's.
53. **`empty-nesting-reads-its-reference`** — C42, den-hoag-9f4bn. A nesting option whose every
    definition was discharged reads what nixpkgs reads. A `submodule` defined only under `mkIf false`
    is its module set over no definitions, so `weft` reads its default `plain`, where it used to abort
    uncatchably. A strict `attrsOf` drops the discharged element, so `bolts` has no `linen`. The
    control, with the condition true, reads `twill` at both.
54. **`module-path-string`** — C43, den-hoag-submodule-admits-path-string-uetyh. A nesting type
    admits what nixpkgs admits as a module: a string naming a module file is the module under
    `either (submodule M) str`, so the union reads `{ key = "sateen"; }` where it used to answer the
    string, and `lint` collects that string as the engine imports it, where it used to drop it with
    no finding.
55. **`element-tree-refuses-per-level`** — C44, den-hoag-0s6zi. A `check = false` nested tree used
    as an `attrsOf` element has no undeclared report, and a key its level does not declare used to
    vanish at exit 0. It is now refused by name when the level holding it is read, one level down as
    well, while an unread level decides nothing; the same tree typed bare still reports the key
    rather than refusing it. The message is `refusals` row 37's.
56. **`relation-entries-store-named-scope`** — C45, den-hoag-3tsd3. gen-view keys a caller's
    identifiers by their text, so a scope named `baseNameOf pkgs.hello`, which carries string
    context, files its datum and reads it back: `relationEntries` answers one entry whose scope and
    datum both keep their context, where the read used to abort with `… is not allowed to refer to a store path`. It is a non-walking read; a view over store-named scopes still aborts in gen-graph
    (den-hoag-u9k7j).
57. **`construct-index`** — this file's own two indices, checked against the live `checks` attrset
    rather than against each other. Two hand-maintained surfaces recorded the same construct set —
    this numbered list, and the `## What v1 declares` table above — and drifted twice in three
    landings because each repair fixed the one it was looking at (`den-hoag-bl06m`). The cell asserts
    the numbered list's own names equal `builtins.attrNames` of the evaluated `checks` attrset, and
    that the table's rows equal the construct labels this list attributes each check to, plus T5 (the
    one construct with no check cell); both comparisons report how many entries they scanned against
    how many they expected, never a bare pass.

T5's forty refusals are not among these fifty-seven: `builtins.tryEval` yields `success` and nothing
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

These are devshell commands, declared in `ci/flake.nix` beside the `ci`, `relock`, `fmt` and `repl`
that gen-harness supplies. `direnv` loads them from `.envrc`; without it, `nix develop ./ci`.

```sh
check-lock            # nix flake check  AND  nix flake check ./ci
check-hub-main        # nix flake check --refresh --override-input gen github:sini/gen  AND  nix flake check ./ci
refusals              # T5's forty planted violations, each driven red by name, each with an unplanted control
```

Each arm runs **both planes**, reports both exit codes on one summary line
(`check-lock: root=0 ci=0`), and exits non-zero if either did. Neither is short-circuited, so a
root failure still reports the `ci/` plane's colour rather than hiding it. Because these scripts
run under `set -euo pipefail`, that is spelled `|| rc=$?` and not `cmd; rc=$?` — the latter exits
on the first red and prints no summary line at all. `check-hub-main`'s second form carries no
`--override-input`: the `ci/` plane declares `gen-harness` and `nixpkgs` and no `gen` at all, so it
does not move with the hub, and nix answers an override for an absent input with a warning at exit
0 — carrying it would be noise that reads like coverage.

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
`genDelivery.project` with no `selectNodes` and exposed no option for one, so a consumer's node
registry had to be named literally `hosts`, and a wrong name failed **silently** — an empty
projection, not an error. It was the same family as the two defects that module's own header records
as carried unfixed (`den-hoag-es9g`): the class-name hardcode and the witness-2 gap. Fixed under
ADR-0035 (`den-hoag-hub-hardcodes-hosts-mxpd5`): the hub takes the attribute path from the consumer,
and this corpus declares `gen.nodeRegistryPath = [ "thimbles" ]`. The sibling output key
`gen.composed.hosts` was the same finding at another site, repaired the same way: the handle
publishes `gen.composed.nodes` (`den-hoag-erp1m`).

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
(`check-lock`'s root arm) — expect it to print `running 0 flake checks` and build nothing: the asserts
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
