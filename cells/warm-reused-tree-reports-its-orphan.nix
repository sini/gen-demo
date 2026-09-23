# `warm-reused-tree-reports-its-orphan` — C32, den-hoag-warm-path-still-discards-mw5t6. C30's seam
# on the WARM path: a re-compose that reuses a leaf typed with gen-merge's nesting seam reports the
# def its nested tree dropped, equal to a cold re-evaluation of the same modules. The leaf's
# presence in `warmDecision.reused` is asserted, so a warm run that remerged it through the cold arm
# cannot pass the cell for the wrong reason.
#
# C32 — the WARM path reports what C30's cold path reports
# (den-hoag-warm-path-still-discards-mw5t6). A re-compose that REUSES a leaf typed
# with gen-merge's nesting seam used to answer `.undeclared = [ ]` for it, so the
# def the nested tree dropped was reported cold and vanished warm. `spoolTree` in
# `.reused` is what makes the cell about the reuse arm: a warm run that remerged
# the leaf would report through the cold arm and pass for the wrong reason. The
# cold re-evaluation of the same modules is the reference the report must equal.
{ asserts, genMerge }:
{
  construct = [ "C32" ];
  check = asserts (
    let
      spoolTreeType =
        (genMerge.evalModuleTree {
          check = false;
          modules = [
            {
              options.known = genMerge.mkOption { type = genMerge.types.str; };
              options.id_hash = genMerge.mkOption { type = genMerge.types.str; };
            }
          ];
        }).type;
      base = [
        { options.spoolTree = genMerge.mkOption { type = spoolTreeType; }; }
        {
          _file = "c32";
          config.spoolTree = {
            known = "k";
            id_hash = "spool:0";
            stray = "S";
          };
        }
      ];
      edited = [
        {
          options.thread = genMerge.mkOption { type = genMerge.types.str; };
          config.thread = "t";
        }
      ];
      lax =
        mods:
        genMerge.evalModuleTree {
          check = false;
          modules = mods;
        };
      warm = genMerge.evalModuleTree {
        check = false;
        modules = base ++ edited;
        warmFrom = lax base;
        editedModules = edited;
      };
    in
    warm.warmDecision.mode == "warm"
    && builtins.elem "spoolTree" warm.warmDecision.reused
    &&
      warm.undeclared == [
        {
          file = "c32";
          path = [
            "spoolTree"
            "stray"
          ];
        }
      ]
    && warm.undeclared == (lax (base ++ edited)).undeclared
  );
}
