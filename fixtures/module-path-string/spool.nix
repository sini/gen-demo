# C43 `module-path-string`: a module file named by a STRING (`toString` of this path). A file in the
# flake source rather than `builtins.toFile`, because CI's `nix flake check --no-build` evaluates
# read-only and cannot import a `toFile` path it never wrote.
{ config.key = "sateen"; }
