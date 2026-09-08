# gen-demo — the acceptance corpus for gen.
#
# Read every exit status UNPIPED. Under zsh a pipeline's per-stage status is `$pipestatus`
# (lowercase), and a piped read of `$?` reports the last stage instead of nix.

default: check

# ARM 1 — the committed flake.lock, the last-green pin.
check:
    nix flake check

# ARM 2 — the same corpus against the hub's current main, so a hub landing that breaks the corpus
# reads red immediately instead of waiting for a relock.
check-hub-main:
    nix flake check --override-input gen github:sini/gen

# NOT a check. The full build of the one target, verified once at delivery and on demand.
build-target:
    nix build .#nixosConfigurations.pewter.config.system.build.toplevel

# The pin advances deliberately: relock, then both arms must be green before it lands.
relock:
    nix flake update gen
