#!/usr/bin/env bash
# gen-demo declaration for gen-harness's staged-tree commit hook (den-hoag-commit-hook-stash-
# shared-checkout-ddjy2, `lib.stagedCommitHook`, which retired the `post-checkout` provisioner of
# den-hoag-worktree-precommit-unreachable-0gsn0): a commit in a real LINKED worktree is judged on
# its staged tree by the one hook devshell entry writes at the common dir, and the commit never
# touches a byte the developer left unstaged. Run against a throwaway clone of THIS repository
# rather than the checkout the devshell is running in -- a real `git worktree add` and a real
# commit are the instrument, and neither belongs in the tree a developer is standing in.
#
# Planted/unplanted, as `ci/refusals.sh` does it, mirroring the construction rather than importing
# it: the installed hook is moved aside for one worktree (planted: the violating commit LANDS, so
# the refusal below is the hook's and nothing else's) and left in place for the next (unplanted:
# the same violating commit is refused, a clean one lands, and an unstaged edit survives both
# byte-identical -- the stash the old shim ran would have rewritten it inside the commit's window).
#
# Reached as the devshell command `worktree-check` (`ci/flake.nix`). Every exit is read UNPIPED.
# Requires the `ci/flake.nix` gen-harness input to carry `lib.stagedCommitHook`: the setup step
# refuses by name when devshell entry installs anything else.
set -u

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
repo_root="$PWD"
fail=0

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

clone="$tmpdir/clone"
git clone --quiet "$repo_root" "$clone" || { echo "FAIL setup: clone failed"; exit 1; }

# Provision the common dir's hook once, exactly as a developer's first `nix develop` does.
if ! (cd "$clone/ci" && nix develop -c true) >"$tmpdir/provision.log" 2>&1; then
  echo "FAIL setup: main-tree devshell provisioning failed"
  sed -n '1,20p' "$tmpdir/provision.log"
  exit 1
fi
hook="$clone/.git/hooks/pre-commit"
if ! grep -qF '# gen-harness: staged-tree commit hook' "$hook" 2>/dev/null; then
  echo "FAIL setup: the staged-tree commit hook is not installed at the common dir after devshell entry"
  exit 1
fi

# $1 label, $2 worktree dir name, $3 file content to stage, $4 wanted commit exit code, $5 output
# substring required on the commit (empty = none checked). Each worktree carries an unstaged edit
# to a tracked file, and its bytes are compared after the commit whatever the commit's exit.
check_worktree() {
  local label="$1" wtdir="$2" content="$3" want_exit="$4" want_grep="$5"
  local wt="$tmpdir/$wtdir"
  if ! git -C "$clone" worktree add "$wt" -b "$wtdir" >"$tmpdir/$wtdir-add.log" 2>&1; then
    echo "FAIL $label: git worktree add failed"
    sed -n '1,10p' "$tmpdir/$wtdir-add.log"
    fail=1
    return
  fi
  printf 'an unstaged edit\n' >> "$wt/README.md"
  local before
  before=$(sha256sum "$wt/README.md")
  printf '%s' "$content" > "$wt/probe.md"
  git -C "$wt" add probe.md
  local out="$tmpdir/$wtdir-commit.out"
  git -C "$wt" commit -m "worktree-check: $label" >"$out" 2>&1
  local ec=$?
  if [ "$ec" != "$want_exit" ]; then
    echo "FAIL $label: commit exit $ec, wanted $want_exit"
    sed -n '1,10p' "$out"
    fail=1
    return
  fi
  if [ -n "$want_grep" ] && ! grep -qF "$want_grep" "$out"; then
    echo "FAIL $label: required substring not found in commit output"
    echo "  wanted: $want_grep"
    fail=1
    return
  fi
  if [ "$(sha256sum "$wt/README.md")" != "$before" ]; then
    echo "FAIL $label: the unstaged edit to README.md changed across the commit"
    fail=1
    return
  fi
  echo "ok   $label (commit exit $ec, unstaged edit byte-identical)"
}

# An unordered-list marker and an emphasis marker mdformat rewrites in place, so a REAL formatter
# run over the staged tree is what refuses, not a missing config wearing a green hat.
bad=$'*emph* and\n* bullet\n'

# ── planted: the hook moved aside, so nothing gates the linked worktree and the violation lands.
mv "$hook" "$tmpdir/pre-commit.hidden"
check_worktree "planted (no hook at the common dir -> the violating commit lands)" \
  wt-planted "$bad" 0 ""
mv "$tmpdir/pre-commit.hidden" "$hook"

# ── unplanted: the installed hook judges the staged tree of each linked worktree.
check_worktree "unplanted violating (staged red -> commit refuses)" \
  wt-red "$bad" 1 "files were modified by this hook"
check_worktree "unplanted clean (staged green -> commit lands)" \
  wt-green $'*emph* and\n' 0 ""

exit $fail
