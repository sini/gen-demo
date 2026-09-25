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
# function, the engines, the cross-row control and the exit. A new row lands by adding one file --
# see README.md, "Adding a construct, a cell or a refusal row".
#
# TWO ENGINES, ONE VERDICT. Sourcing a row only RECORDS its arms; every arm is then evaluated by
# one of two engines and judged by the one `verdict` function below, in the rows' order.
#   nej      ONE `nix-eval-jobs` run over every arm (den v1's `ci.bash`): each worker evaluates the
#            corpus flake ONCE, where a `nix eval` per arm re-evaluated the hub library per arm
#            (~3 s each, ~11 min a run). tryEval cannot read a message, but nix-eval-jobs does not
#            need it to: an arm left to throw UNCAUGHT comes back in the job's own `error` field
#            with its full message, which is what the by-name grep reads.
#   process  one `nix eval --impure --raw` per arm, `REFUSALS_JOBS` at a time.
# nix-eval-jobs links its OWN evaluator (upstream Nix), so it reads a message the way upstream Nix
# words it and no other. `auto` (the default) takes `nej` only when the `nix` on PATH is upstream
# Nix and `process` otherwise, so a Lix or Determinate column still reads every refusal under its
# own evaluator. `REFUSALS_ENGINE=nej|process` forces one.
#
# Reached as the devshell command `refusals` (`ci/flake.nix`), which is what makes the plane
# schedulable: the workflow runs it, and `ci/tests/refusals-pairing.nix` holds the pairing above
# to a cell so a row that loses an arm reds `nix flake check ./ci` rather than passing quietly.
set -u

# Run from the repository root. Every probe below evaluates `builtins.getFlake (toString ./.)`,
# which resolves against the CWD; `just` supplied that by running recipes from the justfile's
# directory, and as a devshell command the script supplies it itself.
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
root="$PWD"
fail=0

# A fresh dir per run -- two concurrent `refusals` runs no longer collide on a fixed /tmp name.
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# den v1's caps: workers bounded so an arm that runs away cannot take the host's memory with it.
workers="${REFUSALS_JOBS:-$(($(nproc) < 8 ? $(nproc) : 8))}"

# $1 label, $2 nix expr, $3 wanted exit code, $4 required stderr substring (empty = none checked),
# $5 file to capture this row's stderr into (for the cross-row control at the end),
# $6 wanted stdout, exact match (empty = none checked -- the planted arms, which refuse before
# producing a value; every unplanted arm passes one, so a construction that refused everything
# cannot pass this arm by exiting 0 with the wrong (or no) value).
labels=() exprs=() want_exits=() want_greps=() errfiles=() want_stdouts=()
check() {
  labels+=("$1")
  exprs+=("$2")
  want_exits+=("$3")
  want_greps+=("$4")
  errfiles+=("$5")
  want_stdouts+=("${6:-}")
}

# Arm $1's verdict, from the exit code, stdout and stderr its engine left in `$tmpdir/arm$1.*` and
# its errfile. An arm with no exit code left behind was never evaluated, and reds as such.
verdict() {
  local i="$1"
  local label="${labels[$i]}" want_exit="${want_exits[$i]}" want_grep="${want_greps[$i]}"
  local errfile="${errfiles[$i]}" want_stdout="${want_stdouts[$i]}"
  local ec out
  ec="$(cat "$tmpdir/arm$i.ec" 2>/dev/null)" || ec="none (the arm was never evaluated)"
  out="$(cat "$tmpdir/arm$i.out" 2>/dev/null)"
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

# ── the engines ──
engine="${REFUSALS_ENGINE:-auto}"
if [ "$engine" = auto ]; then
  case "$(nix --version)" in
  "nix (Nix) "*) engine=nej ;;
  *) engine=process ;;
  esac
fi

nej=() proc=()
if [ "$engine" = nej ]; then
  # An arm reaches the one run by two rewrites of its text: the flake it reads becomes one binding
  # shared by every arm, and its one other relative path literal, `./aspect-cnf.nix`, becomes
  # absolute (the jobs file lives in `$tmpdir`, so a relative literal would resolve there). Any arm
  # still carrying a relative path after that runs as a process instead of reading a wrong file.
  case "$root" in
  *[!A-Za-z0-9._/+-]*)
    echo "FAIL engine: the repository path '$root' cannot be a Nix path literal; set REFUSALS_ENGINE=process"
    exit 1
    ;;
  esac
  {
    echo "let"
    echo "  __refusalsFlake = builtins.getFlake \"$root\";"
    # nix-eval-jobs reports derivations only, and drops any other value from its stream without a
    # word, so each arm is carried on a derivation it never instantiates. \"\${v}\" is the coercion
    # `nix eval --raw` applies.
    echo '  __refusalsArm = v: derivation { name = "refusal-arm"; system = builtins.currentSystem; builder = "/bin/sh"; } // { refusalValue = "${v}"; };'
    echo "in {"
    for i in "${!exprs[@]}"; do
      e="${exprs[$i]//builtins.getFlake (toString .\/.)/__refusalsFlake}"
      e="${e//.\/aspect-cnf.nix/$root/aspect-cnf.nix}"
      if printf '%s' "$e" | grep -qE '(^|[^A-Za-z0-9._/~+-])\.\.?/'; then
        proc+=("$i")
        continue
      fi
      nej+=("$i")
      printf '  arm%s = __refusalsArm (\n%s\n);\n' "$i" "$e"
    done
    echo "}"
  } >"$tmpdir/jobs.nix"
else
  proc=("${!exprs[@]}")
fi

if [ "${#nej[@]}" -gt 0 ]; then
  # den v1's evaluator-death rule: a non-zero nix-eval-jobs exit is a dead evaluator, not a set of
  # verdicts, and whatever it did reach is never tallied.
  nejrc=0
  nix-eval-jobs --impure --no-instantiate --workers "$workers" --max-memory-size 2048 \
    --apply 'd: { v = d.refusalValue; }' "$tmpdir/jobs.nix" \
    >"$tmpdir/jobs.json" 2>"$tmpdir/jobs.err" || nejrc=$?
  if [ "$nejrc" -ne 0 ]; then
    echo "FAIL engine: EVALUATOR FAILED (nix-eval-jobs exit $nejrc) -- no arm is tallied"
    # An arm that aborts past `catch` (a stack overflow) is `fatal` and takes the run's exit with
    # it. No row does today; one that must is run with REFUSALS_ENGINE=process.
    jq -r 'select(.fatal == true) | .attr' "$tmpdir/jobs.json" | while read -r attr; do
      echo "  fatal arm: ${labels[${attr#arm}]:-$attr}"
    done
    cat "$tmpdir/jobs.err"
    exit "$nejrc"
  fi
  # One record per arm: attr, exit, stdout, error. An error is `nix eval`'s exit 1; a record with
  # neither an error nor a value is exit 2, which no arm wants.
  jqrc=0
  jq --raw-output0 '.attr,
      (if .error != null then "1" elif (.extraValue.v | type) == "string" then "0" else "2" end),
      (.extraValue.v // ""),
      (.error // "nix-eval-jobs returned neither an error nor a value")' \
    "$tmpdir/jobs.json" >"$tmpdir/jobs.split" || jqrc=$?
  if [ "$jqrc" -ne 0 ]; then
    echo "FAIL engine: could not read nix-eval-jobs' output (jq exit $jqrc)"
    exit 1
  fi
  while IFS= read -r -d '' attr && IFS= read -r -d '' ec && IFS= read -r -d '' out && IFS= read -r -d '' err; do
    i="${attr#arm}"
    printf '%s' "$ec" >"$tmpdir/arm$i.ec"
    printf '%s' "$out" >"$tmpdir/arm$i.out"
    if [ "$ec" = 0 ]; then : >"${errfiles[$i]}"; else printf '%s\n' "$err" >"${errfiles[$i]}"; fi
  done <"$tmpdir/jobs.split"
fi

for i in "${proc[@]}"; do
  while [ "$(jobs -rp | wc -l)" -ge "$workers" ]; do wait -n; done
  (
    ec=0
    nix eval --impure --raw --expr "${exprs[$i]}" >"$tmpdir/arm$i.out" 2>"${errfiles[$i]}" || ec=$?
    echo "$ec" >"$tmpdir/arm$i.ec"
  ) &
done
wait

for i in "${!labels[@]}"; do verdict "$i"; done
echo "rows: ${#rowfiles[@]} row files sourced from ci/refusals/ (${#labels[@]} arms: ${#nej[@]} through nix-eval-jobs, ${#proc[@]} as processes, $workers at a time)"

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
