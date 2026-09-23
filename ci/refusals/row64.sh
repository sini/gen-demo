# shellcheck shell=bash
# ── row 64 -- a node VALUE where a gen-program declaration takes an identifier is refused by name,
#    catchably (gen-program bkdkg U6, ADR-0025 item 1) ──
# `declaration` used to admit a record as a head or relatum, and `program` then aborted past
# `tryEval` one layer down (`expected a string but found a set`). `declaration` — the one door
# `rule`, `program` and `unresolvedRelata` all normalise through — now refuses it by name. The
# unplanted arm is the live control: identifiers build a program. (The program is built in the
# `let` because a `}` in a `${row/BODY/...}` replacement would close the expansion.)
row64='let
  P = (builtins.getFlake (toString ./.)).inputs.gen.lib.framework.program;
  pewter = { name = "pewter"; };
  prog = head: relatum: P.program {
    declarations = [ { inherit head; relata = [ relatum ]; } ];
    frozen = [ "damask" ];
  };
in BODY'
check "T5 row64 unplanted (identifiers build a program; its atoms are the assertion)" \
  "${row64/BODY/builtins.toJSON (prog \"pewter\" \"damask\").atoms}" 0 "" \
  "$tmpdir/row64-green.err" '["pewter"]'
check "T5 row64 planted   (a node value as a relatum, refused by the declaration's name)" \
  "${row64/BODY/builtins.toJSON (prog \"grosgrain\" pewter).atoms}" 1 \
  "gen-program.declaration: an entry of relata is a set, expected a node identifier (a string)" \
  "$tmpdir/row64-red.err"
check "T5 row64 catchable  (a node value as the head: the refusal is caught by tryEval, not an abort)" \
  "${row64/BODY/if (builtins.tryEval (builtins.deepSeq (prog pewter \"damask\") true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row64-catch.err" 'CAUGHT'
