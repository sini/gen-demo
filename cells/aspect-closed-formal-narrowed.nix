# `aspect-closed-formal-narrowed` — C116. A parametric aspect declared in the corpus's own grammar
# and fired at a context that carries more coords than it reads (`bobbin` beside `thimble`). `tuck` is
# a first-order guard (den-hoag-lwbb1 stage 2b: a context closure crosses the gen-rules door, so the
# aspect is `guard (pred.has "thimble") { … readCtx … }`): it reads only `thimble`, so the extra coord
# never reaches it. Before the context door narrowed, the closure form of this application aborted
# `called with unexpected argument 'bobbin'`, which `tryEval` does not contain. The control is the
# other side of the same condition: a context missing `thimble` is refused, catchably (open world).
{
  asserts,
  genAlgebra,
  genAspects,
  genMerge,
  inputs,
}:
let
  cnf = import ../aspect-cnf.nix;
  t = (genAlgebra.term inputs.gen.lib.substrate.identity.hashIdentity).term;
  tuck =
    (genMerge.evalModuleTree {
      modules = [
        { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
        {
          aspects.tuck = genAspects.guard (genAspects.pred.has "thimble") {
            description = t.concat [
              (t.lit "tuck-")
              (t.readCtx "thimble" [ ])
            ];
          };
        }
      ];
    }).config.aspects.tuck;
  fire = (genAspects.mkGuardVocab cnf).applyGuard;
  wide = fire {
    thimble = "pewter";
    bobbin = "damask";
  } tuck;
  missing = fire { bobbin = "damask"; } tuck;
in
{
  construct = [ "C116" ];
  check = asserts (
    wide.description == "tuck-pewter"
    && !(builtins.tryEval (builtins.deepSeq missing.description null)).success
  );
}
