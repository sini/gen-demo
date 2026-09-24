#!/usr/bin/env bash
# T5 (ADR-0025) -- one plant per enforcer, refused BY NAME. `builtins.tryEval` cannot read a
# refusal's message (that is a property of the builtin, not of Nix -- `den-hoag-9mo`), so the
# by-name half runs here, out of band, rather than as a `checks` cell. Each plant mirrors the
# construction its own C-numbered construct in `constructs/` uses -- never imports it, since a
# standalone plant must not perturb the corpus's own declarations -- and every probe below is run
# BOTH planted (must refuse, by name) and unplanted (must not refuse), because a construction that
# refused unconditionally would pass the planted arm for the wrong reason. Every exit is read
# UNPIPED: a piped `$?` reports the last stage of the pipe, not nix's.
#
# THE ROWS ARE FILES. Every `ci/refusals/*.sh` is one row (or one group of rows sharing a prelude),
# sourced below in version order (`row9` before `row10`); this script holds only the `check`
# function, the cross-row control and the exit. A new row lands by adding one file -- see README.md,
# "Adding a construct, a cell or a refusal row".
#
# Reached as the devshell command `refusals` (`ci/flake.nix`), which is what makes the plane
# schedulable: the workflow runs it, and `ci/tests/refusals-pairing.nix` holds the pairing above
# to a cell so a row that loses an arm reds `nix flake check ./ci` rather than passing quietly.
set -u

# Run from the repository root. Every probe below evaluates `builtins.getFlake (toString ./.)`,
# which resolves against the CWD; `just` supplied that by running recipes from the justfile's
# directory, and as a devshell command the script supplies it itself.
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
fail=0

# A fresh dir per run -- two concurrent `refusals` runs no longer collide on a fixed /tmp name.
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# $1 label, $2 nix expr, $3 wanted exit code, $4 required stderr substring (empty = none checked),
# $5 file to capture this row's stderr into (for the cross-row control at the end),
# $6 wanted stdout, exact match (empty = none checked -- the planted arms, which refuse before
# producing a value; every unplanted arm passes one, so a construction that refused everything
# cannot pass this arm by exiting 0 with the wrong (or no) value).
check() {
  local label="$1" expr="$2" want_exit="$3" want_grep="$4" errfile="$5" want_stdout="${6:-}"
  local out
  out="$(nix eval --impure --raw --expr "$expr" 2>"$errfile")"
  local ec=$?
  if [ "$ec" != "$want_exit" ]; then
    echo "FAIL $label: exit $ec, wanted $want_exit"
    sed -n '1,5p' "$errfile"
    fail=1
    return
  fi
  if [ -n "$want_grep" ] && ! grep -qF "$want_grep" "$errfile"; then
    echo "FAIL $label: required substring not in stderr"
    echo "  wanted: $want_grep"
    fail=1
    return
  fi
  if [ -n "$want_stdout" ] && [ "$out" != "$want_stdout" ]; then
    echo "FAIL $label: stdout mismatch"
    echo "  wanted: $want_stdout"
    echo "  got:    $out"
    fail=1
    return
  fi
  echo "ok   $label (exit $ec)"
}

# ── the rows ──
# `nullglob`, and a count, because an unmatched glob is otherwise passed through as its own literal
# text: `.` of it fails, and a run that sourced NO row would print only the control and exit 0 --
# the plane reading clean because it measured nothing.
shopt -s nullglob
rowfiles=(ci/refusals/*.sh)
if [ "${#rowfiles[@]}" -eq 0 ]; then
  echo "FAIL rows: no row file under ci/refusals/ -- nothing was measured"
  exit 1
fi
mapfile -t rowfiles < <(printf '%s\n' "${rowfiles[@]}" | sort -V)
for rowfile in "${rowfiles[@]}"; do
  # shellcheck source=/dev/null
  . "$rowfile" || {
    echo "FAIL $rowfile: did not source cleanly"
    fail=1
  }
done
echo "rows: ${#rowfiles[@]} row files sourced from ci/refusals/"

# The control below reads rows' stderr by file; `grep` on a file that was never written exits 2,
# which `if grep -q` reads as "no leak". Refuse that instead of passing it.
for errfile in row1 row2 row5 row6 row9 row10 row11 row14 row20 row21 row24 row25 row26 row28 row29 row35 row36 row75 row76; do
  if [ ! -f "$tmpdir/$errfile-red.err" ]; then
    echo "FAIL control: $errfile's planted stderr was never written -- the row it names did not run"
    fail=1
  fi
done

# ── control: the per-row grep must DISCRIMINATE, not just match anything red. Row 2's refusal
# must not appear in row 1's, and row 1's must not appear in row 2's -- if either did, the check
# function above would pass a mismatched row/message pairing and the by-name half would be
# measuring nothing. Extended to the v1.1 rows: row6's `bobbins` message against row9's
# `retired lattice key` message, the two new rows furthest apart in both library and shape.
# Further extended to rows 10/11: both gate the same construct through the same door prefix
# (`gen-view.boundedWellDefinedSchedule:`), so this is the pair most likely to cross-match by
# accident -- row 10 refuses a cyclic component, row 11 refuses a non-minted attrset, and
# neither message may appear in the other's stderr. Extended again to row 14 against row 5, its
# message-distant sibling: both rows are about the DELIVERY TARGET SET (row 5 the projection's
# missing category source, row 14 a collision in the view it selects over) while their refusals
# come from different libraries and share no token, so a leak either way would mean the by-name
# half is matching the area rather than the message. Extended once more to rows 20/21, which are the
# rows 10/11 case in gen-bind: both refuse the SAME `close` call through the same `gen-bind:` door,
# differing only in which guard fires, so they are the pair most able to cross-match by accident.
# Extended a final time to rows 28/29, which are that case in gen-schema: both are kind-plane
# refusals reached through `mkSchemaOption` on the same `thimble` fixture, both open with
# `gen-schema:`, and both are about a NAME the library does not admit -- row 28 a declaration key no
# reader consumes, row 29 a collection key colliding with the library's own vocabulary. They are the
# pair most able to cross-match by accident, and neither message may appear in the other's stderr.
# Extended to rows 35/36: both are gen-merge refusals of one `spool` module behind the same `gen-merge:`
# prefix, row 35 a key the reader does not admit and row 36 a value the foreign type does not admit.
# Extended to rows 75/76, the rows 10/11 case at gen-select's two kind-admission doors: the two
# refusals share every token but the site naming itself, so a leak either way would mean the by-name
# half is matching the library rather than the door.
if grep -qF "unresolved relatum 'pewter'" "$tmpdir/row2-red.err"; then
  echo "FAIL control: row1's message leaked into row2's refusal"
  fail=1
elif grep -qF "not in the frozen set" "$tmpdir/row1-red.err"; then
  echo "FAIL control: row2's message leaked into row1's refusal"
  fail=1
elif grep -qF "not a declared member" "$tmpdir/row9-red.err"; then
  echo "FAIL control: row6's message leaked into row9's refusal"
  fail=1
elif grep -qF "retired lattice key" "$tmpdir/row6-red.err"; then
  echo "FAIL control: row9's message leaked into row6's refusal"
  fail=1
elif grep -qF "received an attrset that" "$tmpdir/row10-red.err"; then
  echo "FAIL control: row11's message leaked into row10's refusal"
  fail=1
elif grep -qF "cyclic component" "$tmpdir/row11-red.err"; then
  echo "FAIL control: row10's message leaked into row11's refusal"
  fail=1
elif grep -qF "no category source" "$tmpdir/row14-red.err"; then
  echo "FAIL control: row5's message leaked into row14's refusal"
  fail=1
elif grep -qF "has conflicting definitions" "$tmpdir/row5-red.err"; then
  echo "FAIL control: row14's message leaked into row5's refusal"
  fail=1
elif grep -qF "thunk-bindings-unmatched" "$tmpdir/row21-red.err"; then
  echo "FAIL control: row20's message leaked into row21's refusal"
  fail=1
elif grep -qF "adapter-malformed" "$tmpdir/row20-red.err"; then
  echo "FAIL control: row21's message leaked into row20's refusal"
  fail=1
elif grep -qF "already a registered node's id" "$tmpdir/row21-red.err"; then
  echo "FAIL control: row24's message leaked into row21's refusal"
  fail=1
elif grep -qF "adapter-malformed" "$tmpdir/row24-red.err"; then
  echo "FAIL control: row21's message leaked into row24's refusal"
  fail=1
elif grep -qF "cannot consume" "$tmpdir/row25-red.err"; then
  echo "FAIL control: row26's message leaked into row25's refusal"
  fail=1
elif grep -qF "definitions that collide at" "$tmpdir/row26-red.err"; then
  echo "FAIL control: row25's message leaked into row26's refusal"
  fail=1
elif grep -qF "is reserved — cannot be used as a collection key" "$tmpdir/row28-red.err"; then
  echo "FAIL control: row29's message leaked into row28's refusal"
  fail=1
elif grep -qF "unrecognised declaration key" "$tmpdir/row29-red.err"; then
  echo "FAIL control: row28's message leaked into row29's refusal"
  fail=1
elif grep -qF "is not of type" "$tmpdir/row35-red.err"; then
  echo "FAIL control: row36's message leaked into row35's refusal"
  fail=1
elif grep -qF "has an unsupported attribute" "$tmpdir/row36-red.err"; then
  echo "FAIL control: row35's message leaked into row36's refusal"
  fail=1
elif grep -qF "adapters.registry.mkContext" "$tmpdir/row75-red.err"; then
  echo "FAIL control: row76's message leaked into row75's refusal"
  fail=1
elif grep -qF "sel.kind expects" "$tmpdir/row76-red.err"; then
  echo "FAIL control: row75's message leaked into row76's refusal"
  fail=1
else
  echo "ok   control (row1/row2, row6/row9, row10/row11, row5/row14, row20/row21, row25/row26, row28/row29, row35/row36 and row75/row76 refusals do not cross-match)"
fi

exit $fail
