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

Every construct is a NAME with one file, `index/<name>.nix` (`{ title; adr; what; }`). The index of
them is generated, never written here: `nix build .#construct-index` renders it (`result` is the
Markdown table: name, legacy id and former names, ADR, what it is). A `C<n>` or `row<n>` id from
before the names (den-hoag-nv8fd) resolves through `legacy-ids.nix`, as does a renamed name.

**Retired: C70, C71 and `refusals` row 93.** They drove gen-merge over a foreign leaf vocabulary
(nixpkgs' `lib.types`, whole or in part) passed as its `types` formal. That mode is withdrawn
(den-hoag-ydro3, OQ-D arm V): `types` is the gen-types library, and gen-merge refuses a `types`
without its check-witness protocol by name. nixpkgs types stay supported as foreign VALUES (C41,
C58, C61, C65, C75, C80). Their guarantee (a foreign vocabulary publishes its own names and a
collision refuses per name, catchably) re-arms on den-hoag-k6m8t when a dedicated
foreign-vocabulary parameter exists.

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

Both `nix flake check` forms, and so both arms below, are **unguarded**: they read a git-filtered
copy of the tree, so an untracked file is absent from either plane and a failing untracked cell
reads green. The guarded command is `nix develop ./ci --command ci`, which refuses on any untracked
file under a declared read root before it runs `ci/tests`: the `ci/` plane's own (`ci/tests`,
`ci/refusals`, `ci/refusals.sh`, `ci/worktree-precommit-check.sh`) and everything the root flake
reads (`cells/`, `constructs/`, `fixtures/`, `gen-modules/`, `aspect-cnf.nix`, `README.md`,
`flake.nix`, `flake.lock`). The remedy is `git add` or move. It does not run the root plane itself,
so run it before either arm below to know the arm saw every file you meant it to.

The root checks are the acceptance criteria. **`cells/` is their index**: each file is one check,
named after the file, and its header comment says what the cell asserts and why. The one check with
no file is `construct-index`, declared in `flake.nix`: it reads the constructs every cell attributes
itself to (the `construct` field) and requires them to equal the names in `index/`, plus
`planted-refusals` (T5) — the one construct with no check cell (`den-hoag-bl06m`). It also requires
every `legacy-ids.nix` id and `renamed` entry to resolve, every name to be `[a-z0-9-]+`, and this
README to carry no hand-written construct table. It reports how many constructs it compared against
how many it expected, never a bare pass.

### Adding a construct, a cell or a refusal row

Every addition is **new files with a name you choose**; no number is drawn, and no list, table,
index or count is edited by hand (den-hoag-nv8fd). A name is `[a-z0-9-]+`, says what the thing is
(the kebab of its title: `addressed-class-crossing`), and is unique within its kind by construction: it is a file
name, so a second unit choosing the same one adds the same path and git reports it at the merge.

- **A construct** is `index/<name>.nix`:

  ```nix
  {
    title = "a hem walk reaches every node";
    adr = "0020";
    what = "`hem-walk`: what the construct is here, and what the cell asserts.";
  }
  ```

  plus at least one cell that names it in its `construct` field (below). An index entry no cell
  names, or a cell naming a construct with no index entry, reds `construct-index`, naming the file.

- **A construct's declarations** go in `constructs/<name>.nix`: a function whose formals are the
  names it reads, returning the names it declares.

  ```nix
  { genScope, nodes }:
  let
    hemGraph = genScope.eval { … } { … } (genScope.buildRoots { … });
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
  # `hem-walk` — hem-walk-reaches-every-node, den-hoag-xxxxx. What the cell asserts, and what
  # would turn it red.
  { asserts, hemGraph }:
  {
    construct = [ "hem-walk-reaches-every-node" ];
    check = asserts (hemGraph.nodes != [ ]);
  }
  ```

  Drive a cell under `nix flake check --no-build` before landing it: that is what CI runs, and a
  store write (`builtins.toFile`) greens locally and reds there.

- **A refusal row** goes in `ci/refusals/<name>.sh`, sourced by `ci/refusals.sh` in file-name order.
  Label every arm `T5 <name> planted …` / `T5 <name> unplanted …` (a third arm is `catchable`), write
  its stderr to `$tmpdir/<name>-red.err` / `-green.err`, and hold its Nix text in the shell variable
  `row_<name>` with every `-` written `_` (a hyphen is not a shell identifier character; a
  hyphenated variable fails at source time with `command not found`). The pairing cell
  (`ci/tests/refusals-pairing.nix`) reads the labels and reds a row left one-sided, a row file whose
  arms it cannot see, and a name two files both label.

  The one shared edit site left is `ci/refusals.sh`'s cross-row control (the `for errfile in …` list
  and the `elif grep … leaked` chain): a row that adds a cross-match control edits it, and two such
  rows touch adjacent lines. That is a textual merge, not an id collision.

- **Renaming** a construct or a row moves its files and adds `<old> = "<new>";` under
  `legacy-ids.nix`'s `renamed.constructs` or `renamed.rows`; the frozen `constructs` / `rows` maps
  are never edited, and the old name and its legacy id keep resolving. A `renamed` entry whose
  target is not a live name, or whose old name is still live, reds `construct-index` (constructs) or
  the pairing cell (rows). `legacy-ids.nix` gains no other key: frozen by convention, not yet by a
  check.

- **Rebasing a unit written against numbers** (a branch drawn before den-hoag-nv8fd): rebase onto
  this tree; then turn its README table row into `index/<name>.nix` (the row's three cells become
  `title`, `adr`, `what`), write that name into its cells' `construct = [ … ]`, rename
  `constructs/c<n>.nix` to `constructs/<name>.nix`, and move a `ci/refusals/row<n>.sh` to
  `ci/refusals/<name>.sh` with its labels, errfiles and `row_<name>` variable renamed (and, if it
  adds a cross-match control, the same names in `ci/refusals.sh`). A row that edits an EXISTING row
  file finds it under its name: `legacy-ids.nix` maps `row133` to it. Its new ids get no number and
  no `legacy-ids.nix` entry; prose citing its old number is left alone.
  A plain `git rebase` of such a branch stops on `modify/delete` (the file was renamed, and the migration
  rewrote too many tokens for git to follow it). Re-apply the edit instead: take the branch's diff,
  rename `row<n>` in its ADDED lines to the name's four forms (the name in the path, the variable
  `row_<name_>`, the label `T5 <name>`, the errfile `$tmpdir/<name>-`), and `git apply` it onto this tree.

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

By default `refusals` evaluates every arm in ONE `nix-eval-jobs` run: each worker evaluates the
corpus once, and an arm that refuses comes back with its message in the job's `error` field, which is
what the by-name check reads. nix-eval-jobs carries its own evaluator, so CI runs
`REFUSALS_ENGINE=process` in every column instead: one `nix eval` per arm, several at a time, each
refusal read in the words of the evaluator that column installed. Both engines feed one verdict
function, and the run's first line names the engine. `REFUSALS_JOBS` sets the parallelism (default:
the core count, at most 8). A dead nix-eval-jobs run reports `EVALUATOR FAILED` and tallies nothing;
a row whose planted arm aborts past `catch` (a stack overflow) kills that run, and runs under
`REFUSALS_ENGINE=process`.

### Two arms, plus the by-name half

These are devshell commands. `ci` is gen-harness's; the other three are declared in `ci/flake.nix`
beside the `relock`, `fmt` and `repl` that gen-harness also supplies. `direnv` loads them from `.envrc`; without it, `nix develop ./ci`.

```sh
ci                    # guarded: refuses on an untracked file under a declared read root, then runs ci/tests
check-lock            # nix flake check  AND  nix flake check ./ci -- unguarded
check-hub-main        # nix flake check --refresh --override-input gen github:sini/gen  AND  nix flake check ./ci -- unguarded
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
this one. C7 gates `config.declaredEdges` plus every CANDIDATE C5's program declares, on or off
(`policyCandidates`, over C1's `registered` set) -- not C2's `edges`, which carries only the
candidates that resolved on -- so the corpus makes one graph claim and two doors read different
sets from it (`den-hoag-6s1t` (iii)). The gate returns its equations and no order: its relation
carries edges that may resolve off. Its Check reads fields of the returned
`gated` record, never of its argument: a cell over the argument would force gen-graph alone (already
reached) and add nothing for gen-view (gate v0's CONSTRUCTION-1, `den-hoag-xgu75`). `refusals`
row 10 plants the cycle `pewter -> grosgrain -> damask -> pewter`; row 11 hands the gate a
hand-assembled attrset carrying the same `index`/`dependencies` fields `mkDeclaredEdges` builds, no
`_type` tag -- `genGraph.isDeclaredEdges` is purely nominal, so this door is the only
construct-granular witness a hand-written stand-in cannot forge (Oracle 1b); row 81 plants
`faille -> grosgrain`, a cycle only through C5's piping candidate, with the policy off.

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
Both the assembly evaluated as a scope (walked with gen-scope's `resolve`; its labelled record read
by gen-graph's `forgetLabels`, `roots`, `leaves`, `cycles`) and gen-select's selector context (`adapters.registry.mkContext`, built over the
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
the shape this corpus uses — the kind value's declarations live in the module its `__functor` imports,
and the sole recompute path used to answer over `[ "name" ]` alone and disagree with the stamp on every instance of it. Measured
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
