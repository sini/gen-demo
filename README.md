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
shown to integrate. This is v0 — the hello step.

Bead: `den-hoag-gen-demo-hello-ptjir`.

## What v0 declares

| | |
| --- | --- |
| one kind | `thimble` |
| one node | `pewter`, a `thimble` |
| one query | the nodes of kind `thimble`, answered by gen-scope |
| one target | a synthetic `nixos` delivery class, realized through the hub |

`gen-modules/corpus.nix` holds the declaration; `aspect-cnf.nix` holds the key-category declaration
that both the tree and the hub read; `flake.nix` holds the query and the three checks.

### The naming rule — invented kinds only

**gen names no entities.** There is no host, user, system, machine or service in the substrate, so a
corpus that declared one would be asserting a vocabulary gen does not have and quietly importing a
framework's model into gen's acceptance criteria. Every kind, node and aspect name here is therefore
a nonsense word: `thimble`, `pewter`, `stitch`. No den vocabulary appears anywhere.

One exception, and it is **imposed rather than chosen**: the node registry is spelled `hosts`. The
hub's `flakeModules/default.nix` calls gen-delivery's `project` without a `selectHosts`, so the
projection takes that function's own default, `v: v.hosts or { }`. A registry under any other name
projects **empty** — no error, no output, just an empty `nixosConfigurations`. See *Findings* below.

## The CI contract

`nix flake check` runs three checks, and they are the acceptance criteria:

1. **`graph-query`** — the assembled graph, queried. gen-scope registers the node set and the kind
   vocabulary, and `nodesOfType "thimble"` is asserted to be exactly `[ "pewter" ]`.
2. **`delivery-projection`** — the delivered projection for the one target: the node projected, and
   the declared `nixos` class collected onto it.
3. **`nixos-instantiate`** — the target instantiated, **not built**: the check writes
   `nixosConfigurations.pewter.config.system.build.toplevel.drvPath` to a file, which runs the whole
   NixOS evaluation and stops at the `.drv`.

### Two arms

```sh
just check            # nix flake check
just check-hub-main   # nix flake check --refresh --override-input gen github:sini/gen
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

**1. `nix flake check` is RED at hub `d6ec9c8` (2026-09-08), and gen-demo is not the cause.**
Checks 2 and 3 abort inside gen with:

```
gen-merge: the option type `aspectsRoot' supplies a `functor' this boundary cannot read …
```

No aspect declaration of any shape evaluates at that rev: `mkAspectOption`, `mkAspectModule` and
`aspectsType` all route through `aspectsRoot`, and gen-merge's pinned revision refuses it. The hub
pins `gen-merge` at `8722a23`, **one commit behind** `gen-merge` main `0c11b23`, and that one commit
is the fix — it retains a stated `binOp` instead of dropping it, so the refusal no longer fires.
Measured: all three checks evaluate green under
`--override-input gen/gen-merge github:sini/gen-merge`. **The repair is a hub relock, not a change
here.**

**2. The hub hardcodes the node-registry name.** `flakeModules/default.nix` calls
`genDelivery.project` with no `selectHosts` and exposes no option for one, so a consumer's node
registry must literally be named `hosts`. It is the same family as the two defects that module's own
header records as carried unfixed (`den-hoag-es9g`): the class-name hardcode and the
witness-2 gap. It fails **silently** — the wrong name yields an empty projection, not an error.

**3. Two stale docs, met while building.** gen-scope's README documents `eval { roots = …; }`; the
formal is `scope`, and `buildNodes` is a tombstone that refuses its own name — `buildRoots` is the
live constructor. gen-aspects' `mkAspectModule` comment says it declares `options.aspects` and
`options.schema`; it declares only `options.aspects`.
