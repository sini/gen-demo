# ── C140 — a policy body on terms, and a guard written as a `when` term (den-hoag-lwbb1 unit 3;
# ADR-0008, ADR-0020, fuci G1). C105's guards, written as condition terms on the declaration, lower to
# the same `pos`/`neg` literals and the well-founded engine reads them exactly as it reads the
# literals written out: a membership guard is solved, never resolved at a context. Beside it, a policy
# body whose every free slot is a term is admitted under its declared coordinates and fired through
# gen-program's interpreter: it fires where its condition holds, emits nothing where the coordinate is
# absent (FALSE under the declared set, not a refusal), and every fired declaration carries an
# identity minted over the sources of what it read, never the values.
{
  genProgram,
  genAlgebra,
  inputs,
}:
let
  T = genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity;
  inherit (T.term)
    all
    eq
    has
    lit
    not
    readCtx
    ;
  decl = head: when: {
    inherit head when;
    relata = [ "bolt" ];
  };
  fact = head: {
    inherit head;
    relata = [ "bolt" ];
  };
  # C105's settled shapes, each guard a `when` term.
  whenDecls = [
    (fact "gusset:bolt")
    (decl "gusset-held:bolt" (all [
      (has "gusset:bolt")
      (not (has "unpicked-gusset:bolt"))
    ]))
    (decl "yoke:bolt" (not (has "gusset-held:bolt")))
    (fact "lining:bolt")
    (decl "lining-held:bolt" (all [
      (has "lining:bolt")
      (not (has "unpicked-lining:bolt"))
    ]))
    (decl "collar:bolt" (has "lining-held:bolt"))
  ];
  onePass =
    declarations:
    genProgram.model {
      program = genProgram.program [ "bolt" ] declarations;
      interpretation = [ ];
      prior = null;
      complete = true;
    };

  # A policy body on terms: a suppression guarded by a value test, and a member whose payload reads
  # the one coordinate its condition covers.
  trimBody = genProgram.body {
    name = "trim";
    declared = [ "spool" ];
    clauses = [
      {
        ctor = "suppress";
        when = eq [
          "spool"
          "fibre"
        ] "silk";
        target = "overlock";
      }
      {
        ctor = "member";
        kind = "trim";
        when = has "spool";
        payload.thread = readCtx "spool" [ "fibre" ];
      }
    ];
  };
  spoolSource = "entity:" + builtins.hashString "sha256" "spool-1";
  fireAt =
    context:
    genProgram.groundInstances {
      sources.spool = spoolSource;
    } context trimBody;
in
{
  whenPass = onePass whenDecls;
  whenYoke =
    (genProgram.declaration {
      when = not (has "gusset-held:bolt");
    } [ "bolt" ] "yoke:bolt").neg;
  trimCodomain = genProgram.deriveCodomain trimBody;
  trimFired = fireAt { spool.fibre = "silk"; };
  trimFiredCotton = fireAt { spool.fibre = "cotton"; };
  trimAbsent = fireAt { };
}
