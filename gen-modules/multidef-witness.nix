# den-hoag-sezf's corpus declaration (ADR-0018: "a component with no declaration in it is not
# landed"). `import-tree` loads every file under `gen.tree` (`./gen-modules`) as its own module, so
# this file's `config.aspects.stitch.binding`/`.trim` are genuine SECOND definitions of the keys
# `corpus.nix` also declares — a real cross-module collision, not one literal attrset trying to
# define a key twice.
#
# `binding` — witness 1 (Arm A, den-hoag-sezf §2 O1a/O1b/O2): a plain freeform key, defined twice
# with differing list values. `merge.mergeDefaultOption` concatenates them; pre-fix the raw
# `{ _type = "merge"; contents = [...]; }` marker leaked into `config.aspects.stitch.binding`
# verbatim instead.
#
# `trim` — witness 2 (Arm B, den-hoag-sezf §2 O12): the same freeform key, this time carrying TWO
# guard-record definitions (`genAspects.guard`/`pred.eq` over the `thimble` kind — the base export
# `whenEq` sugars over,
# see `gen-aspects/lib/guard.nix`). Pre-fix this aborted `flatten` uncatchably; post-fix the two defs
# merge into one fragment carrier. Discharge is per-node, downstream of this declaration (at `damask`
# this fragment survives and the `pewter`-guarded one in `corpus.nix` does not).
{ genAspects, ... }:
{
  config.aspects.stitch = {
    binding = [ "hem" ];
    trim = genAspects.guard (genAspects.pred.eq [ "thimble" "name" ] "damask") "cording";
  };
}
