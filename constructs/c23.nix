# ── C23 — `attrs` as a NULLARY CONTAINER STRATEGY (den-hoag-241d7, ADR-0014's constructing
# arm + ADR-0027). The engine's `attrs` stated a checker and nothing else: no empty value and
# no fold, so an option of that type THREW when nothing defined it — where every container
# type yields its empty — and two modules contributing disjoint keys COLLIDED instead of
# being unioned. A container that cannot be empty and cannot be contributed to from two
# places is not a container, and a corpus whose modules are written by different hands hits
# both on its first day.
#
# Declared on the corpus's own invented vocabulary rather than on a real option, for C15's
# reason: a fixture that borrows a live declaration greens when something ELSE is repaired.
{ genMerge }:
let
  c23Decl = {
    options.selvedge = genMerge.mkOption { type = genMerge.types.attrs; };
  };
  # No definition anywhere and NO `default` — the defaultless half is the whole row. A `default
  # = { }` would green this from the declaration side and say nothing about the type.
  c23Undefined = (genMerge.evalModuleTree { modules = [ c23Decl ]; }).config.selvedge;
  # Two modules, disjoint keys. The fold has to UNION them: picking either definition, or
  # refusing, is the pre-component behaviour.
  c23Disjoint =
    (genMerge.evalModuleTree {
      modules = [
        c23Decl
        { config.selvedge.warp = "flax"; }
        { config.selvedge.weft = "tussah"; }
      ];
    }).config.selvedge;
in
{
  inherit c23Decl c23Undefined c23Disjoint;
}
