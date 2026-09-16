#!/usr/bin/env bash
# gen-demo declaration for den-hoag-worktree-precommit-unreachable-0gsn0's fix (gen-harness
# `25f0840`, "devshell: self-provision a linked worktree's pre-commit config on checkout"):
# the O2/O3 pair from `specs/2026-09-16-gen-worktree-hook-config-spec.md`, run against a
# throwaway clone of THIS repository rather than the checkout the devshell is running in --
# a real `git worktree add` and a real commit are the instrument, and neither belongs in the
# tree a developer is standing in.
#
# O2 is mirrored rather than replayed: reproducing "no self-provisioning hook installed" for
# real would mean pinning gen-harness before this fix, which drags a second flake eval into a
# script whose subject is git, not Nix. Instead the fixed hook is INSTALLED, then moved aside
# for one worktree (planted) and left in place for the next (unplanted) -- the same
# plant/unplant discipline `ci/refusals.sh` uses, mirroring the construction rather than
# importing it, so a standalone plant cannot perturb this corpus's own declarations.
#
# Reached as the devshell command `worktree-check` (`ci/flake.nix`). Every exit is read
# UNPIPED. Requires the `ci/flake.nix` gen-harness input to be at or past `25f0840` -- the
# whole point is exercising a hook this repository's PRE-BUMP pin cannot install.
set -u

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
repo_root="$PWD"
fail=0

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

clone="$tmpdir/clone"
git clone --quiet "$repo_root" "$clone" || { echo "FAIL setup: clone failed"; exit 1; }

# Provision the common dir's hooks once, exactly as a developer's first `nix develop` does --
# this installs pre-commit AND (the fix under test) the `post-checkout` self-provisioner.
if ! (cd "$clone/ci" && nix develop -c true) >"$tmpdir/provision.log" 2>&1; then
  echo "FAIL setup: main-tree devshell provisioning failed"
  sed -n '1,20p' "$tmpdir/provision.log"
  exit 1
fi
hook="$clone/.git/hooks/post-checkout"
if [ ! -x "$hook" ]; then
  echo "FAIL setup: post-checkout hook not installed after devshell entry"
  exit 1
fi

# $1 label, $2 worktree dir name, $3 branch, $4 file content (empty = skip the write/commit
# and just check provisioning), $5 wanted commit exit code, $6 stderr substring required on
# the commit (empty = none checked).
check_worktree() {
  local label="$1" wtdir="$2" branch="$3" content="$4" want_exit="$5" want_grep="$6"
  local wt="$tmpdir/$wtdir"
  if ! git -C "$clone" worktree add "$wt" -b "$branch" >"$tmpdir/$wtdir-add.log" 2>&1; then
    echo "FAIL $label: git worktree add failed"
    sed -n '1,10p' "$tmpdir/$wtdir-add.log"
    fail=1
    return
  fi
  if [ -z "$content" ]; then
    echo "ok   $label (worktree added, no commit requested)"
    return
  fi
  printf '%s' "$content" > "$wt/probe.md"
  git -C "$wt" add probe.md
  local errfile="$tmpdir/$wtdir-commit.err"
  git -C "$wt" commit -m "worktree-check: $label" >"$tmpdir/$wtdir-commit.out" 2>"$errfile"
  local ec=$?
  if [ "$ec" != "$want_exit" ]; then
    echo "FAIL $label: commit exit $ec, wanted $want_exit"
    sed -n '1,10p' "$errfile"
    fail=1
    return
  fi
  if [ -n "$want_grep" ] && ! grep -qF "$want_grep" "$errfile" "$tmpdir/$wtdir-commit.out" 2>/dev/null; then
    echo "FAIL $label: required substring not found in commit output"
    echo "  wanted: $want_grep"
    fail=1
    return
  fi
  echo "ok   $label (commit exit $ec)"
}

# ── O2 (mirrored, planted): the hook that would self-provision is moved aside, so this
# worktree gets no `.pre-commit-config.yaml` -- the pre-fix defect, reproduced by construction
# rather than by an older pin. pre-commit itself (installed above) still runs and refuses.
mv "$hook" "$tmpdir/post-checkout.hidden"
check_worktree "O2 planted (no self-provisioning hook -> commit refuses on missing config)" \
  wt-o2 wt-o2 $'*emph* and\n* bullet\n' 1 "No .pre-commit-config.yaml file was found"
mv "$tmpdir/post-checkout.hidden" "$hook"

# ── O3 (unplanted): the real hook is back in place. Clean file first (GREEN), then the
# violating file the spec's own O3 names -- an unordered-list marker and an emphasis marker
# mdformat rewrites in place, so a REAL formatter run is what refuses the second commit, not
# a missing config wearing a green hat.
check_worktree "O3 clean (self-provisioned worktree, clean file -> commit lands)" \
  wt-o3-clean wt-o3-clean $'*emph* and\n' 0 ""
check_worktree "O3 violating (self-provisioned worktree, formatter rewrites in place -> commit refuses)" \
  wt-o3-bad wt-o3-bad $'*emph* and\n* bullet\n' 1 "files were modified by this hook"

# ── O4: a later, ORDINARY checkout inside the already-provisioned wt-o3-clean worktree must
# not pay the provisioning cost again -- the guard finds the config already present and
# returns immediately. Read as a TIMING bound rather than an invocation count (this script has
# no probe hook of its own to count `nix develop` calls with): P-4 measured first-provisioning
# at ~2-5s on a warm store, so a same-worktree second checkout finishing in well under 1s is
# evidence the provisioning branch was skipped, not raced.
t0=$(date +%s%N)
git -C "$tmpdir/wt-o3-clean" checkout -b wt-o3-second-branch >"$tmpdir/o4.log" 2>&1
o4_ec=$?
t1=$(date +%s%N)
o4_ms=$(( (t1 - t0) / 1000000 ))
if [ "$o4_ec" != 0 ]; then
  echo "FAIL O4: second checkout exit $o4_ec"
  fail=1
elif [ "$o4_ms" -gt 1000 ]; then
  echo "FAIL O4: second checkout took ${o4_ms}ms (>1000ms) -- provisioning likely re-ran"
  fail=1
else
  echo "ok   O4 (second checkout ${o4_ms}ms, no-op guard held)"
fi

exit $fail
