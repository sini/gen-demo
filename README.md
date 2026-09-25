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

| construct                                                 | ADR                      | what it is here                                                                                                                                                                                                                                                                                                                                                                                                 |
| --------------------------------------------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| C1 -- kinds and nodes                                     | 0012                     | two kinds (`thimble`, `bobbin`), four nodes (`pewter`, `damask`, `grosgrain`, `faille`)                                                                                                                                                                                                                                                                                                                         |
| C2 -- edges, queried                                      | 0012, 0019               | `declaredEdges` plus C5's dynamic edge, ONE graph, one named query (`tacks*piping*`)                                                                                                                                                                                                                                                                                                                            |
| C3 -- a binding node                                      | 0016                     | `basting:pewter:grosgrain`, minted at pass 1 over two pass-0 relata                                                                                                                                                                                                                                                                                                                                             |
| C4 -- a movement                                          | 0010, 0024               | a `selvage` channel walked on `tacks`, Λ read off C3's own relata names                                                                                                                                                                                                                                                                                                                                         |
| C4b -- element identity                                   | 0024 arm F               | a diamond mints exactly one element (`diamondMoved`); a collision of identical content across three declarations mints three (`collisionMoved`); a competition key that reads the diamond's own residual admission state SPLITS the one element and refuses by name (`splitKeyed`), live control on `entityOf` keyed by scope instead                                                                           |
| C5 -- a policy program                                    | 0020, 0022, 0033         | a stable model admitting `piping:grosgrain:faille`, which becomes C2's dynamic edge                                                                                                                                                                                                                                                                                                                             |
| C6 -- a delivery                                          | 0028                     | one `nixos` class realized on `pewter`; two Rider limbs (`welt`, `gusset`) that must NOT realize                                                                                                                                                                                                                                                                                                                |
| C7 -- the well-definedness gate                           | 0008 §3, 0030, 0019      | `genView.boundedWellDefinedSchedule` over `config.declaredEdges` (NOT C2's `edges`), contracted through `genGraph.mkNodeRef`/`mkDeclaredEdges`; the Check reads fields of the returned `gated`, never of its argument                                                                                                                                                                                           |
| T2b -- byte parity                                        | 0008                     | `compose`/`override` warm arm byte-identical to a cold `compose`, guarded by `trace.mode`                                                                                                                                                                                                                                                                                                                       |
| C8 -- the contribution protocol                           | 0012, 0014               | `genAssemble.assemble`/`union` over three contributions; shape unions commutatively, content folds by positional authority                                                                                                                                                                                                                                                                                      |
| C9 -- a SHARE class                                       | 0028                     | `genClass` partitions declared content on `weave`, never on the kind boundary; core, gate and invariance all checked                                                                                                                                                                                                                                                                                            |
| C10 -- stratified dispatch                                | 0019                     | `genDispatch` rules whose stratum is STAMPED by `deriveGroup` from their own declared `produces`, none written by hand                                                                                                                                                                                                                                                                                          |
| C11 -- a federated packaged subgraph                      | 0011 §4, 0027            | `genLink.link {sources; wire;}` with a per-origin `keySemantics`; the declared capability survives the exchange                                                                                                                                                                                                                                                                                                 |
| C12 -- a derived product graph + policy-stratum promotion | 0016 rulings 1-2         | `genProduct.productN "cartesian"` over two graphs; the promoted cell joins C1's nodes, C2's edges, C5's own `mdl`                                                                                                                                                                                                                                                                                               |
| C13 -- `foldLayers`                                       | 0017                     | `genAlgebra.record.foldLayers`, all three strategies plus the default channel in one call; `foldNestedLayers` over a literal dotted key `"a.b"` and the nested path `a.b` it spells keeps both as two leaves                                                                                                                                                                                                    |
| C14 -- the closed body-term algebra                       | 0013 row 2, 0023         | `genBind.crossing.term`, a literal `TargetId`; three refusal arms carried as data in the same check cell                                                                                                                                                                                                                                                                                                        |
| C15 -- a cyclic stratum, solved                           | 0008 §2, 0033            | `genMemo.runScc` over a two-member SCC with a higher-stratum dependency, deliberately outside C2's acyclic edge set                                                                                                                                                                                                                                                                                             |
| C16 -- the aspect graph, assembled                        | 0012, 0010 §3            | the corpus's own aspect facts (`genAspects.graphFacts`) contributed through `genAssemble`'s protocol alongside the node registry's membership dimension; queried through both gen-graph's labelled graph and gen-select's context                                                                                                                                                                               |
| C16b -- a foreign reference                               | 0011, 0012, 0014         | `genAspects.keyRef "mill/stitch"` on `aspects.bartack.includes`, published in `foreignIncludesOf` and never as a `declares` edge; total over every node, including the one declaring none                                                                                                                                                                                                                       |
| C17 -- option-set closure                                 | 0016 ruling 5, 0033      | an `extraModules` option on `thimbles` (`shirring`) that is real declared content and CANNOT be an identity key; `thimbles.pewter.id_hash` byte-identical to the stamp minted before it existed                                                                                                                                                                                                                 |
| C18 -- a kinded contribution                              | 0012, 0011               | the same node set assembled through BOTH paths -- C1's direct `genScope.buildRoots` call and `genAssemble.assemble` with `kinds` routed as a call parameter -- asserted IDENTICAL; `kinds` still refused as an eighth contribution key                                                                                                                                                                          |
| C19 -- the discrete/monotone separation                   | 0019, 0020, 0012         | `discreteCtx` clears a two-node cycle's declared in-flight accessors at gen-select's seven non-monotone positions (Datafun's split); `not`/`attrs`/`when` refuse against the writable cycle, `has`/`parentMatches` still answer                                                                                                                                                                                 |
| C20 -- the product adapter's totality doors, real data    | 0035, 0025 item 1        | `adapters.product.mkContext`'s `coordsFor`, wired to C12's real `seamSpace.product.coordsOf`; an under-applied `coordsFor` over the SAME real space now refuses at construction instead of writing a residual function into `__coords`                                                                                                                                                                          |
| C21 -- the stamp survives the relocation                  | 0016 ruling 7, 0033      | the corpus's `thimble` composed the retired way (`imports = [ config.schema.hank ]`) and the relocated way (`inherits = [ "hank" ]`, gen-schema's staged `evalSchema`) mints one `id_hash`; dropping the inheritance MOVES it, which is what makes the equality non-vacuous                                                                                                                                     |
| C22 -- a bounded extent peer-read                         | 0026                     | gen-bind's `mkSystemTerminal` adapter over a real `genDelivery.realize`; one node carries an invented mark admitting no label, and its handed `specialArgs.nodes` is bounded to empty while the mark is named on every withheld peer                                                                                                                                                                            |
| C23 -- `attrs` is a nullary container strategy            | 0014, 0027               | an `attrs` option undefined and defaultless resolves to `{ }` instead of throwing, and two modules contributing disjoint keys are unioned rather than collided; the type stated a checker and nothing else before den-hoag-241d7                                                                                                                                                                                |
| C24 -- the value-injection interim, priced                | 0023 (b)                 | `injectAdapter`'s declared opt-out read from the CONSUMING side: a substrate closure (gen-schema's `__functor`) crosses into `_module.args` and is still applicable there, while a substrate-written DATA position crosses plain -- the matched control that stops the first arm passing for the wrong reason                                                                                                   |
| C25 -- the graph interrogated                             | 0015, 0012               | gen-inspect reached at the hub's published `framework` bucket and materialized over THIS corpus's own graph: four nodes over two kinds and three declared edges become one IR, a SQL query answers over it, an unknown table and an unknown label value are both refused BY NAME, and the walk reports `faille` as the node no declared edge reaches                                                            |
| C26 -- kind inheritance resolves a value                  | 0016 ruling 7, 0033      | the corpus's own `dart` kind inherits `notch`'s `grade` option through the relocated pass (`inherits = [ "notch" ]`); `darts.chambray` sets only `bevel`, so `grade` resolving to `notch`'s default is the inheritance and not two defaults agreeing; a mirrored fixture with `inherits` dropped shows the same option unreachable                                                                              |
| C27 -- rule identity refuses a name-only collision        | 0034                     | two `gen-dispatch` intensional functions sharing the program-point name `notchGuard` mint no override handle from it; the no-override arm still fires both, overriding either now refuses by name                                                                                                                                                                                                               |
| C28 -- an order mark binds a declining declaration        | 0026                     | `viewRelation`'s required `orderMark`, composed with the declaration's own order as a lexicographic product, mark outer, over the corpus's real `tacks`/`gathers` edges out of `pewter`; its order declines (`$` below both arrivals) and the mark overturns it, the identity mark being the arm showing the query alone chose otherwise                                                                        |
| C29 -- a caller-supplied base module arg                  | 0033                     | a kind whose module forces `argand` WHILE DECLARING an option, mounted through `mkInstanceRegistry`'s `specialArgs` and so through `attrsOf`'s rebuild of gen-merge's submodule; withholding the arg on the same kind is refused catchably, which is what makes the stock arm a statement about the channel and not about where `argand` came from                                                              |
| C30 -- an internal nested tree reports its own orphan     | 0025 item 1              | an option typed with gen-merge's own nesting seam (`evalModuleTree`'s `.type`, not `t.submodule`) receives an undeclared key under it at `check = false`; the outer `.undeclared` names it at its full path instead of the def vanishing with `.config` silently smaller, the same key at the tree's top level being the live control                                                                           |
| C31 -- a custom guard form refuses at first use           | 0025 item 1              | gen-aspects' `mkGuardVocab` over a malformed (`reads` missing) and a core-colliding (`eq`) custom form: construction stays total, the first `applyGuard` through the vocabulary refuses though it names neither form, and a sound `fourchette` form is the control that dispatch is not refusing unconditionally                                                                                                |
| C32 -- the warm path reports a reused tree's orphan       | 0025 item 1, 0008        | a warm `evalModuleTree` re-compose that REUSES a nesting-seam leaf (`spoolTree` in `warmDecision.reused`) names the def the nested tree dropped, and its `.undeclared` equals the cold re-evaluation's; before, the warm arm answered `[ ]` for a reused leaf                                                                                                                                                   |
| C33 -- a warm run that reuses nothing says so             | 0008                     | a function-headed base re-composed warm is admitted and remerges every leaf; the hub's `trace.inert` reads `true` with `reused == [ ]`, where `mode == "warm"` alone hid it, and warm-parity's armed run reading `inert == false` is the control                                                                                                                                                                |
| C34 -- a wrapped module keeps its importer's file         | 0025 item 1              | a def reached through `{ _file = "/demo/spool.nix"; imports = [ … ]; }` carries that file in `provenance.spool.defs`, where it used to read the engine's `<gen-merge>` fallback; the value `sateen` is asserted beside it                                                                                                                                                                                       |
| C35 -- the module reader classifies like nixpkgs          | 0025 item 1              | a shorthand key beside `imports` is config (`spool` reads `sateen`, where it read the default); a surplus key beside an explicit `config` is refused catchably, the same module without it being the control, and by name in `refusals` row 31                                                                                                                                                                  |
| C36 -- a refined option under the `mkType` arm            | 0025                     | `bobbin.picks`, refined positive, on a kind built through gen-aspects' `mkType`: the kind's `refinements` name `picks`, and the registry refuses `picks = 0` by name (`refusals` row 32)                                                                                                                                                                                                                        |
| C37 -- one refined type declared twice survives           | 0034                     | `bobbin.picks` declared in two modules of the staged pass with one let-bound refined type; the merge keeps exactly one refinement, read back as its message; two different refinements of one base refuse (`refusals` row 30)                                                                                                                                                                                   |
| C38 -- a function-bearing datum dedups by `==`            | 0025 item 1, 0034        | `movement-dedup-function-datum`: under `byDatum`, one module binding authored at two scopes collapses (Nix `==` is true of one binding) and a fresh literal survives; 2 kept, 1 licensed drop, where the datum used to abort uncatchably in `toJSON`                                                                                                                                                            |
| C39 -- a nesting seam reads a definition as its reference | 0025 item 1              | `nesting-def-reading`: a function def at an `(evalModuleTree …).type` option yields `spool = "sateen"`, where it aborted uncatchably; a `submodule` declaring `key` takes the def's `key = "sateen"`, where it read the default                                                                                                                                                                                 |
| C40 -- a declaration read refuses module syntax           | 0025 item 1              | `declaredOptions` of C35's typo module (`option.weft` beside `options.spool`) is refused by name, where it answered `[ "spool" ]`; the spelled-right twin reads `[ "spool" "weft" ]`; the message is `refusals` row 35's                                                                                                                                                                                        |
| C41 -- a foreign type's check is enforced                 | 0025 item 1              | `spool` typed nixpkgs `lib.types.str` refuses `1` catchably, where gen-merge's own fold used to accept it; the same option given `sateen` is the control, and the refusal is by name in `refusals` row 36                                                                                                                                                                                                       |
| C42 -- a discharged nesting option reads its reference    | 0025 item 1              | `empty-nesting-reads-its-reference`: a `submodule` option defined only under `mkIf false` reads `weft = "plain"`, where it aborted uncatchably; a strict `attrsOf` drops the discharged `linen`, where it kept the key; with the condition true both read `"twill"`                                                                                                                                             |
| C43 -- a module named by a path string is a module        | 0025 item 1              | `module-path-string`: a store-path string under `either (submodule M) str` is the module (`{ key = "sateen"; }`), where the union answered the string; `lint` collects that string as the engine imports it, one finding where it dropped it                                                                                                                                                                    |
| C44 -- a nested tree as a container element refuses       | 0025 item 1              | `element-tree-refuses-per-level`: a key a `check = false` tree does not declare, inside an `attrsOf` element, is refused when its level is read, where it vanished at exit 0; the same tree typed bare still reports it; the message is `refusals` row 37's                                                                                                                                                     |
| C45 -- a scope named after a package                      | 0025 item 1              | `relation-entries-store-named-scope`: a scope named `baseNameOf pkgs.hello` carries string context; gen-view keys it by its text, so the datum filed there is read back as one entry whose scope and datum keep their context, where the read used to abort (`… is not allowed to refer to a store path`)                                                                                                       |
| C46 -- a walk over store-named scopes                     | 0025 item 1              | `walk-store-named-scope`: a labeled graph over scopes named `baseNameOf pkgs.hello` and `baseNameOf pkgs.jq` is walked `contains*` from `pewter`; every answered name keeps its context and the graph orders, where the walk used to abort (`… is not allowed to refer to a store path`)                                                                                                                        |
| C47 -- a nested tree typed bare reads its own config      | 0025 item 1, 0008 item 2 | `bare-tree-reads-its-own-config`: a `check = true` tree whose leaf `sub` is another tree defined `mkIf config.bolt.flag …` reads `sub.k = "s"`, where it aborted with infinite recursion; `sub.bogus` is refused read deep and a value at a sibling read, and `.undeclared` names it; a strict warm evaluation over a lax prior goes cold and says why                                                          |
| C48 -- a union member that is not a checker               | 0025 item 1              | `union-member-refuses-by-name`: `union [ (submodule …) str ]` over `{ key = "sateen"; }` is refused catchably, where it aborted (`attribute 'verify' missing`); `union [ str int ]` over `"sateen"` is the control; the message is `refusals` row 43's                                                                                                                                                          |
| C49 -- a schedule over separator-bearing names            | 0025 item 1              | `movement-schedule-separator-names`: two units whose scope and channel names carry `/` order `["consumer","producer"]`, where the `/`-joined cell keys collided and the schedule was refused; the `-` arm is the control                                                                                                                                                                                        |
| C50 -- an SCC entered at its larger member                | 0009, 0022               | `scc-lowlink-late-entry`: gen-graph's `lowlink` arm over `awl → twill → spool → twill` tags {spool, twill} by its smallest member `spool`, not the DFS root `twill`; it equals `fbNode` on the whole record, and `cyclicEdgesWhere` through it answers the `neg` edge inside the component and not the one leaving `awl`                                                                                        |
| C51 -- a pre-order walk past the old ceilings             | 0009, 0022, 0032         | `preorder-walk-past-the-old-ceilings`: gen-graph's `expandPreorder` over a star of 40,001, `foldReach` over a star of 8,001, and all four walks (`ancestorsOf` too) over a chain of 20,000 return whole, where the recursive walks aborted or refused past a depth cap; on `awl → twill → spool → heddle` with back-edges the order is `awl, twill, spool, heddle`, and a seeded `spool` prunes to `awl, twill` |
| C52 -- a cycle named by its walk, over nodes only         | 0009, 0025 item 1        | `cycle-witness-and-domain`: gen-graph's `cycles` over {hem, seam, yoke, tag, cuff} answers [hem seam tag yoke] and `cyclePaths` the walk `hem → seam → yoke`, not the shorter `hem → seam`, with `tag` by its self-loop; `topoOrderKahn` reports the same walks; an edge from `cuff` to `selvedge`, not a node, is refused by `cycles`, `cyclePaths` and `condensation` catchably, where `cycles` answered it   |
| C53 -- a store path's string mints as its text            | 0034, 0016 ruling 4      | `mint-context-stance`: through the hub's `substrate.identity.hashIdentity`, the context-carrying `inputs.gen.outPath` mints its context-free twin's identity as a value; a kind or label carrying that context mints as its text, and the kind identity carries no context, where it carried the store path's and a context-carrying label aborted the mint uncatchably                                         |
| C54 -- reachability over the corpus graph                 | 0015, 0006               | `inspect-reaches-over-the-corpus-graph`: `reaches` from `pewter` over `tacks` answers `damask grosgrain pewter`, where the edge query answers `grosgrain` alone; the `tacks*` walk agrees, `faille` is in no row from another node, and `why` on `damask` names `tacks:grosgrain:damask`; at a pin with no program route the query refuses `reaches` by name                                                    |
| C55 -- a node set grows its own kind off a value          | 0033, 0008 §3            | `nta-same-kind-growth`: a `skein` host's `nta` yields children of kind `skein`, its `strand` family keyed by the evaluated `picked` and its `twist` family keyed by a `strand` child's evaluated `dye` (`madder`); `allNodeIds` holds the host and its three children, and `picked = [ "weft" ]` reads `[ "weft" ]`, where `mkKind` refused `nta` as an unexpected argument                                     |
| C56 -- the three identity regimes                         | 0034                     | `identity-regimes`: through the hub's mint, `whipstitch {thread=madder}` built twice mints ONE identity, `woad` another and a second `revision` a third, all named `whipstitch`; a sealed pair decides past a refusing `__id` and surfaces any other key's refusal; `converge` fires `madder` and `woad` where a name key dropped one; a same-name unmigrated pair, `closure` differing: unequal; rows 77/78    |
| C58 -- an `addCheck`'d nixpkgs leaf is not its base       | 0034                     | `foreign-addcheck-leaf-does-not-unify`: through the hub's `modules.types.typeEq`, `addCheck str p` and `addCheck str q` compare unequal where both minted as `str` and compared equal; the same binding still equals itself and two separately built `listOf str` still unify                                                                                                                                   |
| C59 -- a restricted product and its membership index      | 0012 clause 2            | `restricted-product-membership-index`: `genProduct.restrict` over a needle × thread product by one relation; the two pairs are its cells, a non-member is refused, and the restriction record carries the relation's cellId-keyed index as a field                                                                                                                                                              |
| C60 -- an `internal` primitive is an identity key         | 0016 ruling 5            | `internal-primitive-is-identity-key`: two `brass` grommets differing only in `lot`, `internal` and `readOnly`, mint distinct identities and `_identityKeys` is `crimp lot name`; two differing only in `tally`, declared `identity = false`, mint one                                                                                                                                                           |
| C61 -- a v2 type's ad-hoc check override is refused       | 0025 item 1              | `foreign-v2-check-override`: `spool` typed nixpkgs `attrsOf str // { check = isAttrs; }`, and a `submodule // { check = isAttrs; }`, are refused, where gen-merge used to accept the first and nixpkgs erases the second without a word; the `addCheck` spelling and the stock submodule read `sateen`; by name in `refusals` rows 79/80                                                                        |
| T5 -- planted refusals                                    | 0025                     | every enforcer in `ci/refusals/`, each driven red by name via `refusals`                                                                                                                                                                                                                                                                                                                                        |

`gen-modules/corpus.nix` holds the C1-C6 declarations plus C16's own tree growth; `aspect-cnf.nix`
holds the key-category declaration that both the tree and the hub read; `constructs/` holds the
queries and every construct's standalone fixtures, one file per construct; `cells/` holds the
`checks`, one file per cell; `flake.nix` holds only the wiring that discovers both, plus the
`construct-index` cell over this table; `ci/refusals/` holds T5's by-name half, one file per row,
which runs out of band because `builtins.tryEval` cannot read a refusal's message.

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
and no other: the **root** flake's checks, one per file in `cells/`, and **`ci/`**'s six harness
cells (`default` — the batch asserter over `ci/tests` — plus `treefmt-tree-root`,
`mdformat-plugins`, `agents-md-citations`, `ci-plane-coverage`, `ci-self-input`). `check-lock` and
`check-hub-main` each run **both**, which is `den-hoag-dq6mw`: while they ran the root form alone,
a seeded red in the `ci/` plane left `check-lock` exiting 0 and printing *"all checks passed!"*, so
its green read as suite cover and was not.

The root checks are the acceptance criteria. **`cells/` is their index**: each file is one check,
named after the file, and its header comment says what the cell asserts and why. The one check with
no file is `construct-index`, declared in `flake.nix`: it reads the constructs every cell attributes
itself to (the `construct` field) and requires them to equal this README's `## What v1 declares`
table, plus T5 — the one construct with no check cell (`den-hoag-bl06m`). It reports how many rows
it scanned against how many it expected, never a bare pass.

### Adding a construct, a cell or a refusal row

Every addition is **one new file**; no list, index or count anywhere is edited by hand.

- **A construct's declarations** go in `constructs/<name>.nix`: a function whose formals are the
  names it reads, returning the names it declares.

  ```nix
  { genGraph, nodes }:
  let
    hemGraph = genGraph.labeledFrom { … };
  in
  {
    inherit hemGraph;
  }
  ```

  Every construct file and every module arg (`lib`, `pkgs`, `config`, `inputs`, the `gen*` libraries)
  is one namespace, so any file may read a name another declares. A name declared twice is refused,
  naming both files; a name nothing declares is refused, naming the file that reads it.

- **A check cell** goes in `cells/<check-name>.nix`: a function of the names it reads, returning
  `{ construct; check; }`. `asserts` is already bound to the cell's own name, so a red names the cell.

  ```nix
  # `hem-walk` — C50, den-hoag-xxxxx. What the cell asserts, and what would turn it red.
  { asserts, hemGraph }:
  {
    construct = [ "C50" ];
    check = asserts (hemGraph.nodes != [ ]);
  }
  ```

  A cell attributed to a construct this README's table does not carry reds `construct-index`, so a
  NEW construct is the one addition that also adds a table row. Drive a cell under `nix flake check --no-build` before landing it: that is what CI runs, and a store write (`builtins.toFile`) greens
  locally and reds there.

- **A refusal row** goes in `ci/refusals/<id>.sh`, sourced by `ci/refusals.sh` in version order.
  Label every arm `T5 <id> planted …` / `T5 <id> unplanted …` (a third arm is `catchable`): the
  pairing cell (`ci/tests/refusals-pairing.nix`) reads the labels and reds a row left one-sided, or a
  row file whose arms it cannot see. A new row takes any id no existing file uses.

T5's refusals are not among these cells: `builtins.tryEval` yields `success` and nothing
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
refusals              # T5's planted violations (ci/refusals/), each driven red by name, each with an unplanted control
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
Within one evaluation a minted identity simply is what it is; a move is only nameable where TWO
evaluations are in hand, and the substrate holds two in exactly one place, `warmFrom`. So the row
builds the prior evaluation and the warm re-compose in a single expression, which is what makes a
by-name refusal reachable from one `nix eval` at all. A COLD plant would exit 0 on both arms and
measure nothing. The edit is at a declared identity position, `thimbles.pewter.spool`, and the two
arms are one token apart: `mkForce "linen"` re-defines the value the prior minted, a dirty
contribution that moves no identity, and `mkForce "wool"` moves `pewter`. The unplanted arm's exact
stdout is the corpus's own unmoved stamp, so a refusal keyed on dirtiness alone, which would destroy
reuse for every consumer, fails that arm. A third arm declares an option nothing defines and is
admitted warm without forcing it. `internal` plays no part: it is presentation only, and an
internal primitive is an identity key like any other.

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
