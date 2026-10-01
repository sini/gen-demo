# `aspect-closed-formal-narrowed` — C116. A parametric aspect whose formal set is CLOSED (`tuck`'s
# `{ thimble }:`, no ellipsis), declared in the corpus's own grammar and applied at a context that
# carries more coords than it declares (`bobbin` beside `thimble`). gen-aspects' context door hands a
# closure with formals exactly those formals, so the extra coord never reaches it. Before the door
# narrowed, this application aborted `called with unexpected argument 'bobbin'`, which `tryEval` does
# not contain, so the whole check plane went down rather than this cell failing. The control is the
# other side of the same door: the context missing `thimble` is still refused, catchably.
{
  asserts,
  genAspects,
  genMerge,
}:
let
  cnf = import ../aspect-cnf.nix;
  tuck =
    (genMerge.evalModuleTree {
      modules = [
        { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
        { aspects.tuck = { thimble }: { description = "tuck-${thimble}"; }; }
      ];
    }).config.aspects.tuck;
  wide = tuck {
    thimble = "pewter";
    bobbin = "damask";
  };
  missing = tuck { bobbin = "damask"; };
in
{
  construct = [ "C116" ];
  check = asserts (
    wide.description == "tuck-pewter"
    && !(builtins.tryEval (builtins.deepSeq missing.description null)).success
  );
}
