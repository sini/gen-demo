# `seam-head-provenance` — C12c, den-hoag-eh6x8. Owner-overridden standing guard: the other Oracle 3
# rows guard a VALUE a cell already reads, and a value assertion cannot tell "`seamHead` computed
# from `seamCoords`" apart from "`seamHead` restated as the same literal" — both evaluate to
# `"seam:pewter:grosgrain"`. This cell reads no value; it reads the source of `constructs/c12.nix`
# for the one line binding `seamHead` and requires it to interpolate BOTH `seamCoords.thimble` and
# `seamCoords.bobbin`. A literal has no such line and reds this cell by name while leaving every
# value cell — including `product-promotion` — unmoved, because the literal and the derivation
# produce the identical string.
#
# C12c — the coordinate's PROVENANCE, standing (owner override 2026-09-14, exit
# sitting Q10, den-hoag-eh6x8). The fourteen other Oracle 3 rows guard a VALUE a
# cell already reads; a value assertion cannot tell "`seamHead` computed from
# `seamCoords`" apart from "`seamHead` restated as the same literal" — both
# evaluate to the identical string, `"seam:pewter:grosgrain"`. So this cell reads
# no value at all: it reads the corpus's OWN SOURCE for the one line binding
# `seamHead` and requires it to interpolate BOTH `seamCoords.thimble` and
# `seamCoords.bobbin`. A literal has no such line. Without this cell, ADR-0016
# ruling 2 — "the promoted node must be a function of the product or the ruling
# is prose" — is prose.
#
# No construction closes this without a scan: a Nix value carries no provenance
# once forced, so a `let`-bound RHS accepts a hand-written literal in exactly the
# syntactic position it accepts a derived expression, and nothing in the type or
# module system distinguishes them at the call site. A source-text scan is the
# only instrument that sees the difference; there is no by-construction fix here.
#
# Hardened 2026-09-15 against two measured gaps in the first cut:
#  (1) a literal with a hand-added trailing comment mentioning both coordinates
#      satisfied the old whole-line `hasInfix` check, because the check read the
#      comment text along with the code. Fixed by scanning only the code half of
#      the line, cut at its first `#`. That cut is UNSOUND in general — several
#      gen-* purity suites carry `#` inside string literals a naive cut would
#      swallow — but it holds for THIS line specifically: `seamHead`'s value is
#      built only from `seamCoords.thimble` / `.bobbin`, both plain identifiers
#      (`pewter`, `grosgrain`, …) with no `#` in their vocabulary, so nothing in
#      this line's code half can legitimately contain one. If a coordinate value
#      ever gains a `#`, this cut needs the real lexer the general case does.
#  (2) `lib.findFirst (lib.hasInfix "seamHead = ")` matched this cell's OWN quoted
#      search string and only read line 96 first because line 96 sorts earlier in
#      the file than this cell — a layout property nobody declared. Fixed by
#      requiring the match to be a PREFIX of the trimmed line (`seamHead = ` at
#      column 0, not anywhere in the line), which this cell's own code never is:
#      it assigns `seamHeadLine`/`codeOf`, not `seamHead`.
#
# Residual, not closed: a `seamHead` binding split across more than one line, or a
# legitimate coordinate value that itself contains `#`, both defeat this cell —
# closing either needs a real Nix lexer, not a line scan.
{ asserts, lib }:
{
  construct = [ ];
  check =
    let
      lines = lib.splitString "\n" (builtins.readFile ../constructs/c12.nix);
      codeOf = line: lib.head (lib.splitString "#" line);
      isSeamHeadBinding = line: lib.hasPrefix "seamHead = " (lib.trim (codeOf line));
      seamHeadLine = lib.findFirst isSeamHeadBinding null lines;
      seamHeadCode = if seamHeadLine == null then null else codeOf seamHeadLine;
    in
    asserts (
      seamHeadCode != null
      && lib.hasInfix "seamCoords.thimble" seamHeadCode
      && lib.hasInfix "seamCoords.bobbin" seamHeadCode
    );
}
