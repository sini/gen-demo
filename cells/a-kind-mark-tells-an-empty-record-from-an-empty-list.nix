# `a-kind-mark-tells-an-empty-record-from-an-empty-list` — den-hoag-0pwbu. One declaration literal of a kind
# `gusset` under two schema evaluations, holding `{ }` in one and `[ ]` in the other at a kept collection, is two
# values, so it is two kinds: two marks, `kindEq` false, and nixpkgs' `lib.evalModules`, which keeps one module per
# reference key, keeps both constructions, so the option `fold` both declare is declared twice and refused. Two
# `{ }`s are one kind and nixpkgs keeps one; `[ ]` against `[ "a" ]` is the control that separates. Before, the mark
# and the key read `{ }` as the empty list of its names, so the pair was one kind and nixpkgs dropped one of the two
# silently.
{
  asserts,
  genMerge,
  genSchema,
  lib,
}:
let
  T = genMerge.types;
  schema = genSchema.mkSchemaOption { collections.trims.type = T.anything; };
  gussetOf =
    v:
    (genMerge.evalModuleTree { } [
      { options.schema = schema; }
      { config.schema.gusset.trims = v; }
    ]).config.schema.gusset;
  # the same kind declaring an option `fold` with a default: nixpkgs refuses two declarations that both state a
  # default, so it serves `fold` where it kept one construction and refuses where it kept two. (A default is an open
  # component the mark seals, so `kindEq` is read on `gussetOf`, which declares no option.)
  gussetFold =
    v:
    (genMerge.evalModuleTree { } [
      { options.schema = schema; }
      {
        config.schema.gusset = {
          trims = v;
          options.fold = genMerge.mkOption {
            type = T.str;
            default = "d";
          };
        };
      }
    ]).config.schema.gusset;
  kept =
    a: b:
    let
      r =
        builtins.tryEval
          (lib.evalModules {
            modules = [
              (gussetFold a)
              (gussetFold b)
            ];
          }).config.fold;
    in
    if r.success then 1 else 2;
  pair = a: b: {
    marks = (gussetOf a).__mint.minted == (gussetOf b).__mint.minted;
    kindEq = genSchema.kindEq (gussetOf a) (gussetOf b);
    kept = kept a b;
  };
in
{
  construct = [ "a-kind-key-splits-in-nixpkgs-where-its-mark-splits" ];
  check = asserts (
    pair { } [ ] == {
      marks = false;
      kindEq = false;
      kept = 2;
    }
    &&
      pair [ ] { } == {
        marks = false;
        kindEq = false;
        kept = 2;
      }
    &&
      pair { } { } == {
        marks = true;
        kindEq = true;
        kept = 1;
      }
    &&
      pair [ ] [ "a" ] == {
        marks = false;
        kindEq = false;
        kept = 2;
      }
  );
}
