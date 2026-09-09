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

Bead: `den-hoag-gen-demo-demo-constructs-0k3ix`.

## What v1 declares

Four nodes across two kinds, three declared edges, one policy program admitting a fourth (dynamic)
edge, a binding node, a movement, a delivery to one target through two registries, and the
incremental plane's decision crossing.

| construct | ADR | what it is here |
| --- | --- | --- |
| C1 -- kinds and nodes | 0012 | two kinds (`thimble`, `bobbin`), four nodes (`pewter`, `damask`, `grosgrain`, `faille`) |
| C2 -- edges, queried | 0012, 0019 | `declaredEdges` plus C5's dynamic edge, ONE graph, one named query (`tacks*piping*`) |
| C3 -- a binding node | 0016 | `basting:pewter:grosgrain`, minted at pass 1 over two pass-0 relata |
| C4 -- a movement | 0010, 0024 | a `selvage` channel walked on `tacks`, Λ read off C3's own relata names |
| C5 -- a policy program | 0020, 0022, 0033 | a stable model admitting `piping:grosgrain:faille`, which becomes C2's dynamic edge |
| C6 -- a delivery | 0028 | one `nixos` class realized on `pewter`; two Rider limbs (`welt`, `gusset`) that must NOT realize |
| T2b -- byte parity | 0008 | `compose`/`override` warm arm byte-identical to a cold `compose`, guarded by `trace.mode` |
| T5 -- planted refusals | 0025 | five enforcers, each driven red by name via `just refusals` |

`gen-modules/corpus.nix` holds the declarations; `aspect-cnf.nix` holds the key-category declaration
that both the tree and the hub read; `flake.nix` holds the queries and the seven `checks`; the
`justfile`'s `refusals` recipe holds T5's by-name half, which runs out of band because
`builtins.tryEval` cannot read a refusal's message.

### The naming rule — invented kinds only

**gen names no entities.** There is no host, user, system, machine or service in the substrate, so a
corpus that declared one would be asserting a vocabulary gen does not have and quietly importing a
framework's model into gen's acceptance criteria. Every kind, node and aspect name here is therefore
a nonsense word: `thimble`, `bobbin`, `pewter`, `damask`, `grosgrain`, `faille`, `stitch`, `welt`,
`gusset`, `basting`. No den vocabulary appears anywhere.

One exception, and it is **imposed rather than chosen**: the node registry is spelled `hosts`. The
hub's `flakeModules/default.nix` calls gen-delivery's `project` without a `selectHosts`, so the
projection takes that function's own default, `v: v.hosts or { }`. A registry under any other name
projects **empty** — no error, no output, just an empty `nixosConfigurations`. See *Findings* below.
The second registry, `bobbins`, carries no such imposition and is free to invent; C6's extra
`project` call names it explicitly through `selectHosts`.

## The CI contract

`nix flake check` runs seven checks, and they are the acceptance criteria:

1. **`graph-query`** — C1 + C2, both doors. gen-scope registers the two kinds and four nodes;
   gen-graph's named query walks `tacks*` then `piping*`; gen-select's second door is read with an
   explicit per-id `kindFor` over the heterogeneous node union.
2. **`binding-node`** — C3. The binding minted, identified by its own labelled relata.
3. **`movement`** — C4. The movement's value, and Λ read off C3's own relata names by construction.
4. **`policy-edge`** — C5. The policy program's stable model, total, and the derived edge admitted.
5. **`delivery-projection`** — C6. The node set, the one collected class, both Rider limbs absent
   from the classes despite both being present in the aspect body, and the bobbin door under an
   invented name.
6. **`warm-parity`** — T2b. The warm decision byte-identical to a cold one, with the guard
   (`trace.mode == "warm"`) included.
7. **`nixos-instantiate`** — the target instantiated, **not built**: the check writes
   `nixosConfigurations.pewter.config.system.build.toplevel.drvPath` to a file, which runs the whole
   NixOS evaluation and stops at the `.drv`.

T5's five refusals are not among these seven: `builtins.tryEval` yields `success` and nothing else,
so a refusal's message is unreadable to any `checks.default` cell (`den-hoag-9mo`). They run by name
through `just refusals` instead (below).

### Two arms, plus the by-name half

```sh
just check            # nix flake check
just check-hub-main   # nix flake check --refresh --override-input gen github:sini/gen
just refusals         # T5's five planted violations, each driven red by name, each with an unplanted control
```

The committed `flake.lock` is the **last-green pin**. The second arm evaluates the same corpus against
the hub's **current main**, so a hub landing that breaks the corpus reads red immediately instead of
waiting for a relock.

The full build of the target is **not** a check — it is verified once at delivery and on demand:

```sh
just build-target     # nix build .#nixosConfigurations.pewter.config.system.build.toplevel
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

**2. The hub hardcodes the node-registry name.** `flakeModules/default.nix` calls
`genDelivery.project` with no `selectHosts` and exposes no option for one, so a consumer's node
registry must literally be named `hosts`. It is the same family as the two defects that module's own
header records as carried unfixed (`den-hoag-es9g`): the class-name hardcode and the
witness-2 gap. It fails **silently** — the wrong name yields an empty projection, not an error.
Worked around, not repaired here: `bobbins` is the second registry, under an invented name, reached
through C6's extra `project` call with an explicit `selectHosts`
(`den-hoag-hub-hardcodes-hosts-mxpd5`).

**3. Two stale docs, met while building, still stale at the v1 pin.** gen-scope's README documents
`eval { roots = …; }`; the formal argument is `scope`, and `buildNodes` is a tombstone that refuses
its own name — `buildRoots` is the live constructor. gen-aspects' `mkAspectModule` comment says it
declares `options.aspects` and `options.schema` together; it declares only `options.aspects` —
`gen-modules/corpus.nix` declares `options.schema` itself, from the same `aspectSchema` value, for
exactly this reason.
