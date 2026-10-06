# shellcheck shell=bash
# ── row 53 -- the library reads an element's declared letters, never its derived `member`
#    (gen-view l83dk; p79do Q1: an element tag is a CLAIM, ADR-0025 item 1) ──
# `edgeLabels` publishes `member` as a function of `letters`, and the carrier used to APPLY it: a
# hand-built alphabet whose `member` was replaced aborted past `tryEval` on its result ("expected a
# Boolean"), and one whose `letters` were extended kept the old `member` and was admitted with a
# letter colliding with a relation name. The library now tests membership against `letters`
# itself, so the planted alphabet -- a letter `gimp` that is also the relation's name, carried by an
# alphabet whose `member` answers 42 -- is refused by name for the collision. Row 48's
# pewter/grosgrain declaration; the arms differ by the alphabet alone (`layers` ranks whatever it
# declares). The unplanted arm asserts the answer, and the catchable arm is row 33's form.
row_library_reads_an_elements_declared_letters='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  genuine = genView.edgeLabels { letters = [ "tacks" ]; };
  labels = LABELS;
  admission = genScope.wellFormed { alphabet = labels.letters; expression = "tacks*"; };
  order = genScope.labelOrder { alphabet = labels.letters; layers = [ labels.letters ]; endOfPath = -1; };
  channel = genView.dataOrder { channel = "selvage"; keyOf = c: c.scope; };
  relation = genView.viewRelation { engine = genScope;
    definition = genView.viewDefinition {
      inherit channel admission order;
      relation = "gimp"; root = "pewter"; direction = "outbound"; wellFormed = _: true;
      distance = s: s.distance + 1;
      tieSet = genView.tieSets.union; empty = [ ];
      combine = genView.combines.listAppend; dedup = genView.dedups.none;
    };
    graph = genView.scopeGraph {
      carrier = genView.carrier {
        inherit labels;
        relatumLabels = genView.relatumLabels { names = [ ]; };
        labelWellFormedness = admission; labelOrder = order; dataOrder = channel;
        relations = genView.relations { names = [ "gimp" ]; };
      };
      scopes = [ "grosgrain" "faille" "pewter" ];
      edges.tacks = id: { pewter = [ "faille" "grosgrain" ]; faille = [ "grosgrain" ]; }.${id} or [ ];
      data = [ { scope = "grosgrain"; relation = "gimp"; datum = [ "cambric" ]; } ];
    };
    marks = _: [ ];
    orderMark = genScope.labelOrder { alphabet = labels.letters; layers = [ labels.letters ]; endOfPath = 0; };
  };
in BODY'
row_library_reads_an_elements_declared_lettersunplanted="${row_library_reads_an_elements_declared_letters/LABELS/genuine}"
row_library_reads_an_elements_declared_lettersplant='genuine // { letters = [ "tacks" "gimp" ]; member = _: 42; }'
row_library_reads_an_elements_declared_lettersplanted="${row_library_reads_an_elements_declared_letters/LABELS/$row_library_reads_an_elements_declared_lettersplant}"
check "T5 library-reads-an-elements-declared-letters unplanted (a genuine alphabet; the answer is the assertion)" \
  "${row_library_reads_an_elements_declared_lettersunplanted/BODY/builtins.toJSON relation.value}" 0 "" \
  "$tmpdir/library-reads-an-elements-declared-letters-green.err" '["cambric"]'
check "T5 library-reads-an-elements-declared-letters planted   (a letter colliding with R, behind a forged member, refused by name)" \
  "${row_library_reads_an_elements_declared_lettersplanted/BODY/builtins.toJSON relation.value}" 1 \
  "gen-view.carrier: 'gimp' is both a letter of L and a name in R" \
  "$tmpdir/library-reads-an-elements-declared-letters-red.err"
check "T5 library-reads-an-elements-declared-letters catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_library_reads_an_elements_declared_lettersplanted/BODY/if (builtins.tryEval (builtins.deepSeq relation.value true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/library-reads-an-elements-declared-letters-catch.err" 'CAUGHT'
