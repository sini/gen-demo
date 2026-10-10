# `one-equality-reads-its-producers-witnesses`. gen-algebra's `conservativeEq` is the one equality, and
# gen-types' `typeEq` is that binding. A producer declares which of its fields witness its mark
# (`__witness`), and the equality reads them when it decides, so it gives the type discipline's answer
# on every population a type or a kind arrives in:
#   1. a `//` copy of a type (`int` with a `verify` admitting everything) and of a kind (`grommet` with
#      its options dropped) keeps the mark, and is refused by name, never answered `true`;
#   2. nixpkgs `addCheck` over `int`, re-tied as gen-merge's import door re-ties it, keeps `int`'s mark
#      beside a rewritten check, and is compared, so it is not `int`;
#   3. two foreign records with a back-edge (`description` is the record) decide `false` before `==`
#      walks the edge, where the bare record `==` aborts the evaluator uncatchably.
# Each has an honest twin deciding `true`, so a relation refusing or separating everything cannot pass.
{
  asserts,
  genAlgebra,
  genMerge,
  inputs,
  lib,
}:
let
  eq = genAlgebra.conservativeEq;
  decides = e: (builtins.tryEval (builtins.deepSeq e e)).success;
  int = genMerge.types.int;
  schema = inputs.gen.lib.substrate.schema;
  grommet =
    (genMerge.evalModuleTree { } [
      { options.schema = schema.mkSchemaOption { }; }
      {
        config.schema.grommet.options.eyelets = genMerge.mkOption {
          type = int;
          default = 8;
        };
      }
    ]).config.schema.grommet;
  # nixpkgs `addCheck` over `int`, re-tied as gen-merge's import door re-ties a record whose check a wrapper
  # rewrote: its completion witness returns it, and it carries `int`'s mark
  short =
    let
      s = lib.types.addCheck int (n: n < 3) // {
        __typeSelf = _: s;
      };
    in
    s;
  mk =
    tag:
    let
      r = {
        _type = "option-type";
        name = "gauge";
        nestedTypes = { };
        description = r;
        check = v: v == tag;
      };
    in
    r;
  g = mk 1;
in
{
  construct = [ "the-one-equality-reads-its-producers-witnesses" ];
  check = asserts (
    !(decides (eq int (int // { verify = _: null; })))
    && eq int int
    && !(eq int genMerge.types.str)
    && !(decides (eq grommet (grommet // { options = { }; })))
    && eq grommet grommet
    && !(eq int short)
    && eq short short
    && !(eq g (mk 2))
    && eq g g
  );
}
